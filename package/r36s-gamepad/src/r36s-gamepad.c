// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * r36s-gamepad: present the R36S controls as one gamepad.
 *
 * The buttons (gpio-keys) and the analog sticks (adc-joystick) are separate
 * input devices, but games such as Quake II use a single gamepad. This grabs
 * both and feeds their events into one uinput device, "R36S Gamepad". Its
 * button codes are the ones SDL's automatic gamepad mapping expects, so no
 * SDL_GAMECONTROLLERCONFIG is needed:
 * - SDL follows the Xbox driver for the left and top face buttons (BTN_X is
 *   the left one, BTN_Y the top one), so those two are swapped;
 * - the R36S's Select, Start, stick clicks and FN come in as
 *   BTN_TRIGGER_HAPPY1-5 and go out as BTN_SELECT, BTN_START, BTN_THUMBL,
 *   BTN_THUMBR and BTN_MODE.
 * Everything else, including the stick axes, passes through unchanged.
 *
 * Usage: r36s-gamepad (run as root, before udev sets up the input devices)
 */

#include <errno.h>
#include <fcntl.h>
#include <linux/input.h>
#include <linux/uinput.h>
#include <poll.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#define BUTTONS_NAME	"gpio-keys"
#define STICKS_NAME	"adc-joystick"
#define GAMEPAD_NAME	"R36S Gamepad"

#define BITS_PER_LONG	(8 * sizeof(long))
#define NLONGS(n)	(((n) + BITS_PER_LONG - 1) / BITS_PER_LONG)
#define TEST_BIT(bit, array) \
	(((array)[(bit) / BITS_PER_LONG] >> ((bit) % BITS_PER_LONG)) & 1)

static const struct {
	unsigned short from, to;
} key_map[] = {
	{ BTN_NORTH, BTN_Y },		/* top ("X" on the R36S) */
	{ BTN_WEST, BTN_X },		/* left ("Y" on the R36S) */
	{ BTN_TRIGGER_HAPPY1, BTN_SELECT },
	{ BTN_TRIGGER_HAPPY2, BTN_START },
	{ BTN_TRIGGER_HAPPY3, BTN_THUMBL },
	{ BTN_TRIGGER_HAPPY4, BTN_THUMBR },
	{ BTN_TRIGGER_HAPPY5, BTN_MODE },	/* FN */
};

static volatile sig_atomic_t stop;

static void on_signal(int sig)
{
	(void)sig;
	stop = 1;
}

static unsigned short map_key(unsigned short code)
{
	size_t i;

	for (i = 0; i < sizeof(key_map) / sizeof(key_map[0]); i++) {
		if (key_map[i].from == code)
			return key_map[i].to;
	}
	return code;
}

/* Open the event device called @name, and take it for ourselves */
static int open_grabbed(const char *name)
{
	char path[32], devname[64];
	int i, fd;

	for (i = 0; i < 32; i++) {
		snprintf(path, sizeof(path), "/dev/input/event%d", i);
		fd = open(path, O_RDONLY | O_CLOEXEC);
		if (fd < 0)
			continue;
		if (ioctl(fd, EVIOCGNAME(sizeof(devname)), devname) >= 0 &&
		    strcmp(devname, name) == 0) {
			if (ioctl(fd, EVIOCGRAB, 1) < 0) {
				fprintf(stderr, "r36s-gamepad: can't grab %s: %s\n",
					path, strerror(errno));
				close(fd);
				return -1;
			}
			return fd;
		}
		close(fd);
	}
	fprintf(stderr, "r36s-gamepad: no \"%s\" input device\n", name);
	return -1;
}

static int create_gamepad(int buttons, int sticks)
{
	unsigned long keys[NLONGS(KEY_CNT)] = { 0 };
	unsigned long axes[NLONGS(ABS_CNT)] = { 0 };
	struct uinput_setup setup = { 0 };
	struct uinput_abs_setup abs;
	int fd, code;

	if (ioctl(buttons, EVIOCGBIT(EV_KEY, sizeof(keys)), keys) < 0 ||
	    ioctl(sticks, EVIOCGBIT(EV_ABS, sizeof(axes)), axes) < 0) {
		perror("r36s-gamepad: EVIOCGBIT");
		return -1;
	}

	fd = open("/dev/uinput", O_WRONLY | O_CLOEXEC);
	if (fd < 0) {
		perror("r36s-gamepad: /dev/uinput");
		return -1;
	}
	ioctl(fd, UI_SET_EVBIT, EV_KEY);
	ioctl(fd, UI_SET_EVBIT, EV_ABS);
	for (code = 0; code < KEY_CNT; code++) {
		if (TEST_BIT(code, keys))
			ioctl(fd, UI_SET_KEYBIT, map_key(code));
	}
	for (code = 0; code < ABS_CNT; code++) {
		if (!TEST_BIT(code, axes))
			continue;
		memset(&abs, 0, sizeof(abs));
		abs.code = code;
		if (ioctl(sticks, EVIOCGABS(code), &abs.absinfo) < 0 ||
		    ioctl(fd, UI_ABS_SETUP, &abs) < 0) {
			perror("r36s-gamepad: axis setup");
			close(fd);
			return -1;
		}
	}

	/*
	 * No vendor or product ID, so SDL and Ebitengine identify the gamepad by
	 * its name and use their automatic mapping. gpio-keys' IDs (0001:0001,
	 * version 0100) match other handhelds in their gamepad databases:
	 * Ebitengine leaves SDL's name checksum out of its GUIDs, so it took this
	 * for an Anbernic RG28XX (D-pad on a hat, no sticks).
	 */
	setup.id.bustype = BUS_HOST;
	strcpy(setup.name, GAMEPAD_NAME);
	if (ioctl(fd, UI_DEV_SETUP, &setup) < 0 ||
	    ioctl(fd, UI_DEV_CREATE) < 0) {
		perror("r36s-gamepad: creating the device");
		close(fd);
		return -1;
	}
	return fd;
}

/* Copy one batch of events from @in to @out; false once @in has gone */
static int forward(int in, int out)
{
	struct input_event ev[64];
	ssize_t n;
	int i, count;

	n = read(in, ev, sizeof(ev));
	if (n < 0)
		return errno == EINTR || errno == EAGAIN;
	if (n == 0)
		return 0;
	count = n / sizeof(ev[0]);
	for (i = 0; i < count; i++) {
		if (ev[i].type == EV_KEY)
			ev[i].code = map_key(ev[i].code);
		else if (ev[i].type != EV_ABS &&
			 !(ev[i].type == EV_SYN && ev[i].code == SYN_REPORT))
			continue;	/* scan codes, SYN_DROPPED */
		if (write(out, &ev[i], sizeof(ev[i])) != sizeof(ev[i]))
			return 0;
	}
	return 1;
}

int main(void)
{
	struct pollfd fds[2];
	int buttons, sticks, gamepad, i;

	buttons = open_grabbed(BUTTONS_NAME);
	sticks = open_grabbed(STICKS_NAME);
	if (buttons < 0 || sticks < 0)
		return 1;
	gamepad = create_gamepad(buttons, sticks);
	if (gamepad < 0)
		return 1;

	signal(SIGTERM, on_signal);
	signal(SIGINT, on_signal);
	fds[0].fd = buttons;
	fds[1].fd = sticks;
	fds[0].events = fds[1].events = POLLIN;
	while (!stop) {
		if (poll(fds, 2, -1) < 0) {
			if (errno == EINTR)
				continue;
			perror("r36s-gamepad: poll");
			break;
		}
		for (i = 0; i < 2; i++) {
			if ((fds[i].revents & (POLLERR | POLLHUP)) ||
			    ((fds[i].revents & POLLIN) &&
			     !forward(fds[i].fd, gamepad)))
				stop = 1;
		}
	}

	ioctl(gamepad, UI_DEV_DESTROY);
	return 0;
}
