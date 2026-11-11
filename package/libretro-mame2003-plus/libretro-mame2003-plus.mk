################################################################################
#
# libretro-mame2003-plus
#
################################################################################

LIBRETRO_MAME2003_PLUS_VERSION = 13da075ad51067928e7186289b4bbdb9a7c2e1bb
LIBRETRO_MAME2003_PLUS_SITE = $(call github,libretro,mame2003-plus-libretro,$(LIBRETRO_MAME2003_PLUS_VERSION))
LIBRETRO_MAME2003_PLUS_LICENSE = MAME licence (non-commercial)
LIBRETRO_MAME2003_PLUS_LICENSE_FILES = LICENSE.md

# The flags go in through the environment, not the make command line:
# the Makefile appends its own to CFLAGS, CXXFLAGS and LDFLAGS.
define LIBRETRO_MAME2003_PLUS_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) \
		-C $(@D) -f Makefile platform=unix \
		GIT_VERSION='" $(shell printf %.7s $(LIBRETRO_MAME2003_PLUS_VERSION))"'
endef

define LIBRETRO_MAME2003_PLUS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/mame2003_plus_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/mame2003_plus_libretro.so
endef

$(eval $(generic-package))
