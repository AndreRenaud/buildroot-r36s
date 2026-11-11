################################################################################
#
# libretro-fbneo
#
################################################################################

LIBRETRO_FBNEO_VERSION = a836e52198aa5ce1f54be7b050e44872a1223797
LIBRETRO_FBNEO_SITE = $(call github,libretro,FBNeo,$(LIBRETRO_FBNEO_VERSION))
LIBRETRO_FBNEO_LICENSE = FBNeo licence (non-commercial)
LIBRETRO_FBNEO_LICENSE_FILES = src/license.txt

# The flags go in through the environment, not the make command line:
# the Makefile appends its own to CFLAGS, CXXFLAGS and LDFLAGS.
#
# All the drivers are built (arcade and consoles). There is no dynamic
# recompiler for AArch64 to enable: USE_X64_DRC is x86-64 only, and
# USE_CYCLONE and HAVE_NEON (-mvectorize-with-neon-quad) are for 32-bit
# ARM.
define LIBRETRO_FBNEO_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) \
		-C $(@D)/src/burner/libretro -f Makefile platform=unix \
		GIT_VERSION=$(shell printf %.7s $(LIBRETRO_FBNEO_VERSION))
endef

define LIBRETRO_FBNEO_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/src/burner/libretro/fbneo_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/fbneo_libretro.so
endef

$(eval $(generic-package))
