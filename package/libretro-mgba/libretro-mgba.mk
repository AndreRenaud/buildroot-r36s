################################################################################
#
# libretro-mgba
#
################################################################################

LIBRETRO_MGBA_VERSION = 7a12d6d4b9acb14c0ae62c9166b6a2f3d08007f6
LIBRETRO_MGBA_SITE = $(call github,libretro,mgba,$(LIBRETRO_MGBA_VERSION))
LIBRETRO_MGBA_LICENSE = MPL-2.0
LIBRETRO_MGBA_LICENSE_FILES = LICENSE

# mGBA only builds with CMake: the libretro fork has no Makefile. These
# are the options libretro's own CI uses; LIBMGBA_ONLY leaves out the
# frontends and every optional external library.
LIBRETRO_MGBA_CONF_OPTS = \
	-DLIBMGBA_ONLY=ON \
	-DBUILD_LIBRETRO=ON
LIBRETRO_MGBA_MAKE_OPTS = mgba_libretro

define LIBRETRO_MGBA_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/mgba_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/mgba_libretro.so
endef

$(eval $(cmake-package))
