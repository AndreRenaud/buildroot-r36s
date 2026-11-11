################################################################################
#
# libretro-snes9x
#
################################################################################

LIBRETRO_SNES9X_VERSION = fae2fea08f74180759ef540ee94259213f503480
LIBRETRO_SNES9X_SITE = $(call github,libretro,snes9x,$(LIBRETRO_SNES9X_VERSION))
LIBRETRO_SNES9X_LICENSE = Snes9x licence (non-commercial)
LIBRETRO_SNES9X_LICENSE_FILES = LICENSE

# The flags go in through the environment, not the make command line:
# the Makefile appends its own to CFLAGS, CXXFLAGS and LDFLAGS.
define LIBRETRO_SNES9X_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) \
		-C $(@D)/libretro -f Makefile platform=unix \
		GIT_VERSION='" $(shell printf %.7s $(LIBRETRO_SNES9X_VERSION))"'
endef

define LIBRETRO_SNES9X_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/libretro/snes9x_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/snes9x_libretro.so
endef

$(eval $(generic-package))
