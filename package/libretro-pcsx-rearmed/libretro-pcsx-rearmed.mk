################################################################################
#
# libretro-pcsx-rearmed
#
################################################################################

LIBRETRO_PCSX_REARMED_VERSION = 7b0e8f8fadfbce3d170d195b9d9eecaabfa08c8e
LIBRETRO_PCSX_REARMED_SITE = $(call github,libretro,pcsx_rearmed,$(LIBRETRO_PCSX_REARMED_VERSION))
LIBRETRO_PCSX_REARMED_LICENSE = \
	GPL-2.0+, \
	BSD-3-Clause (libchdr, zstd), \
	MIT (miniz, libretro-common), \
	Public Domain (LZMA SDK)
LIBRETRO_PCSX_REARMED_LICENSE_FILES = \
	COPYING \
	deps/libchdr/LICENSE.txt \
	deps/libchdr/deps/lzma-26.02/LICENSE

# The flags go in through the environment, not the make command line:
# the Makefile appends its own to CFLAGS and LDFLAGS.
#
# The Makefile takes the architecture from "$(CC) -dumpmachine". On ARM
# and AArch64 it selects the "ari64" dynamic recompiler rather than
# Lightrec, and on AArch64 the NEON GPU plugin (its C version, compiled
# for ASIMD); its "unix" platform adds no -mcpu/-march of its own. The
# frontend/libpicofe submodule is not used by the libretro build.
define LIBRETRO_PCSX_REARMED_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) \
		-C $(@D) -f Makefile.libretro platform=unix \
		GIT_VERSION='" $(shell printf %.7s $(LIBRETRO_PCSX_REARMED_VERSION))"'
endef

define LIBRETRO_PCSX_REARMED_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/pcsx_rearmed_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/pcsx_rearmed_libretro.so
endef

$(eval $(generic-package))
