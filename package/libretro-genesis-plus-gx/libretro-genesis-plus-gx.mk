################################################################################
#
# libretro-genesis-plus-gx
#
################################################################################

LIBRETRO_GENESIS_PLUS_GX_VERSION = b9c2316441978d4015ba30e9a95d9b0e6f8ee981
LIBRETRO_GENESIS_PLUS_GX_SITE = $(call github,libretro,Genesis-Plus-GX,$(LIBRETRO_GENESIS_PLUS_GX_VERSION))
LIBRETRO_GENESIS_PLUS_GX_LICENSE = Genesis Plus GX licence (non-commercial)
LIBRETRO_GENESIS_PLUS_GX_LICENSE_FILES = LICENSE.txt

# The flags go in through the environment, not the make command line:
# the Makefile appends its own to CFLAGS, CXXFLAGS and LDFLAGS.
define LIBRETRO_GENESIS_PLUS_GX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) \
		-C $(@D) -f Makefile.libretro platform=unix \
		GIT_VERSION='" $(shell printf %.7s $(LIBRETRO_GENESIS_PLUS_GX_VERSION))"'
endef

define LIBRETRO_GENESIS_PLUS_GX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/genesis_plus_gx_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/genesis_plus_gx_libretro.so
endef

$(eval $(generic-package))
