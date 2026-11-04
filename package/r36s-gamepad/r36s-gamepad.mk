################################################################################
#
# r36s-gamepad
#
################################################################################

R36S_GAMEPAD_VERSION = 1.0
R36S_GAMEPAD_SITE = $(R36S_GAMEPAD_PKGDIR)/src
R36S_GAMEPAD_SITE_METHOD = local
R36S_GAMEPAD_LICENSE = GPL-2.0+

define R36S_GAMEPAD_BUILD_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -Wall -Wextra \
		-o $(@D)/r36s-gamepad $(@D)/r36s-gamepad.c
endef

define R36S_GAMEPAD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/r36s-gamepad $(TARGET_DIR)/usr/sbin/r36s-gamepad
endef

$(eval $(generic-package))
