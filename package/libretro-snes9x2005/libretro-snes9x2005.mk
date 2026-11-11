################################################################################
#
# libretro-snes9x2005
#
################################################################################

LIBRETRO_SNES9X2005_VERSION = a79dfe9047e7fec58808aefe48ad2bf499c7af11
LIBRETRO_SNES9X2005_SITE = $(call github,libretro,snes9x2005,$(LIBRETRO_SNES9X2005_VERSION))
LIBRETRO_SNES9X2005_LICENSE = Snes9x licence (non-commercial), MIT (libretro port)
LIBRETRO_SNES9X2005_LICENSE_FILES = copyright

# The flags go in through the environment, not the make command line:
# the Makefile appends its own to CFLAGS, CXXFLAGS and LDFLAGS.
define LIBRETRO_SNES9X2005_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) \
		-C $(@D) -f Makefile platform=unix \
		GIT_VERSION='" $(shell printf %.7s $(LIBRETRO_SNES9X2005_VERSION))"'
endef

define LIBRETRO_SNES9X2005_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/snes9x2005_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/snes9x2005_libretro.so
endef

$(eval $(generic-package))
