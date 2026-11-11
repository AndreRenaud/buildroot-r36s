################################################################################
#
# retroarch
#
################################################################################

RETROARCH_VERSION = 1.22.2
RETROARCH_SITE = $(call github,libretro,RetroArch,v$(RETROARCH_VERSION))
RETROARCH_LICENSE = GPL-3.0+
RETROARCH_LICENSE_FILES = COPYING
RETROARCH_DEPENDENCIES = \
	host-pkgconf \
	alsa-lib \
	libdrm \
	libegl \
	libgbm \
	libgles \
	udev \
	zlib

# RetroArch has its own configure script ("quickbuild"), which takes
# the usual --enable/--disable options but is not autoconf.
#
# Video: the KMS/DRM context (libdrm + GBM + EGL) with OpenGL ES. With
# OpenGL ES the "gl" driver is the GLES2-level one (it uses GLES3
# features when built with --enable-opengles3); the "glcore" driver
# and its slang shaders (glslang, SPIRV-Cross) are left out.
# Audio: ALSA. Input: udev (evdev) for both input and joypads.
# Menu: RGUI only, which needs no assets.
RETROARCH_CONF_OPTS = \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-kms \
	--enable-egl \
	--enable-opengles \
	--enable-opengles3 \
	--enable-alsa \
	--enable-udev \
	--enable-threads \
	--enable-zlib \
	--enable-rgui \
	--disable-builtinzlib \
	--disable-opengl \
	--disable-opengl1 \
	--disable-opengl_core \
	--disable-glx \
	--disable-slang \
	--disable-glslang \
	--disable-builtinglslang \
	--disable-spirv_cross \
	--disable-vulkan \
	--disable-vulkan_display \
	--disable-x11 \
	--disable-xrandr \
	--disable-xinerama \
	--disable-wayland \
	--disable-qt \
	--disable-sdl \
	--disable-sdl2 \
	--disable-videocore \
	--disable-caca \
	--disable-sixel \
	--disable-pulse \
	--disable-pipewire \
	--disable-jack \
	--disable-oss \
	--disable-tinyalsa \
	--disable-al \
	--disable-rsound \
	--disable-roar \
	--disable-microphone \
	--disable-networking \
	--disable-networkgamepad \
	--disable-ssl \
	--disable-online_updater \
	--disable-update_cores \
	--disable-update_core_info \
	--disable-update_assets \
	--disable-discord \
	--disable-cheevos \
	--disable-translate \
	--disable-ffmpeg \
	--disable-mpv \
	--disable-ssa \
	--disable-materialui \
	--disable-xmb \
	--disable-ozone \
	--disable-shaderpipeline \
	--disable-langextra \
	--disable-freetype \
	--disable-libusb \
	--disable-hid \
	--disable-blissbox \
	--disable-parport \
	--disable-v4l2 \
	--disable-videoprocessor \
	--disable-cdrom \
	--disable-systemd \
	--disable-dbus \
	--disable-xdelta \
	--disable-flac \
	--disable-crtswitchres

# CROSS_COMPILE only has to be non-empty: it stops the script adding
# the build machine's library directories. The compilers come from
# CC/CXX, pkg-config from PKG_CONF_PATH.
define RETROARCH_CONFIGURE_CMDS
	cd $(@D) && \
		$(TARGET_CONFIGURE_OPTS) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		PKG_CONF_PATH="$(PKG_CONFIG_HOST_BINARY)" \
		./configure $(RETROARCH_CONF_OPTS)
endef

define RETROARCH_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

# "make install" also installs upstream's all-comments retroarch.cfg, a
# desktop file, an icon and man pages. Only the executable is wanted;
# the configuration belongs to the board.
define RETROARCH_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/retroarch $(TARGET_DIR)/usr/bin/retroarch
endef

$(eval $(generic-package))
