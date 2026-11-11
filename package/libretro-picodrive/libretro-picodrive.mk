################################################################################
#
# libretro-picodrive
#
################################################################################

LIBRETRO_PICODRIVE_VERSION = 1890c2932234c9d30f4cd3851d02228baae8f09e
LIBRETRO_PICODRIVE_SITE = https://github.com/libretro/picodrive.git
LIBRETRO_PICODRIVE_SITE_METHOD = git
# libchdr, dr_libs, emu2413 (and cyclone68000, libpicofe: unused here)
LIBRETRO_PICODRIVE_GIT_SUBMODULES = YES
LIBRETRO_PICODRIVE_LICENSE = PicoDrive licence (MAME-like, non-commercial)
LIBRETRO_PICODRIVE_LICENSE_FILES = COPYING

# The flags go in through the environment, not the make command line:
# the Makefile appends its own to CFLAGS and LDFLAGS.
#
# The Makefile takes the architecture from "$(CC) -dumpmachine" and
# turns on the SH2 dynamic recompiler (32X) for the ones that have a
# code emitter, aarch64 included. The Cyclone 68000 and DrZ80 cores are
# 32-bit ARM assembly, so other architectures use FAME/C and CZ80.
#
# PLATFORM_TREMOR=1: use the bundled Tremor rather than whatever Vorbis
# decoder happens to be in staging. HOSTCC builds tools/make_carthw_c,
# which runs on the build machine.
#
# With _LARGEFILE64_SOURCE (in Buildroot's TARGET_CFLAGS) dr_mp3 calls
# fopen64(), which libretro's VFS layer does not redirect the way it
# does fopen(): a FILE */RFILE * mix-up that GCC 14 rejects.
# _FILE_OFFSET_BITS=64 alone gives the same 64-bit file offsets.
LIBRETRO_PICODRIVE_CFLAGS = \
	$(filter-out -D_LARGEFILE64_SOURCE,$(TARGET_CFLAGS))

define LIBRETRO_PICODRIVE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(LIBRETRO_PICODRIVE_CFLAGS)" \
		$(MAKE) -C $(@D) -f Makefile.libretro platform=unix \
		HOSTCC="$(HOSTCC)" \
		PLATFORM_TREMOR=1 \
		GIT_REVISION="-$(shell printf %.7s $(LIBRETRO_PICODRIVE_VERSION))"
endef

define LIBRETRO_PICODRIVE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/picodrive_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/picodrive_libretro.so
endef

$(eval $(generic-package))
