################################################################################
#
# libretro-mupen64plus-next
#
################################################################################

LIBRETRO_MUPEN64PLUS_NEXT_VERSION = 15bada85906593376e8fd697f1b0b3af3a20f512
LIBRETRO_MUPEN64PLUS_NEXT_SITE = $(call github,libretro,mupen64plus-libretro-nx,$(LIBRETRO_MUPEN64PLUS_NEXT_VERSION))
LIBRETRO_MUPEN64PLUS_NEXT_LICENSE = \
	GPL-2.0+, \
	Libpng (libpng), \
	Zlib (zlib, minizip), \
	BSD-2-Clause (xxHash), \
	MIT (libretro-common)
LIBRETRO_MUPEN64PLUS_NEXT_LICENSE_FILES = \
	LICENSE \
	GLideN64/LICENSE \
	mupen64plus-core/LICENSES
LIBRETRO_MUPEN64PLUS_NEXT_DEPENDENCIES = host-pkgconf libegl libgles

# The Makefile takes ARCH from "uname -m" of the build machine, and the
# dynamic recompiler from ARCH: both have to be given. Its "unix"
# platform is the only one that adds no -mcpu/-march of its own, so the
# CPU tuning is Buildroot's.
#
# Only the recompilers below exist; the others (and anything unknown)
# get the cached interpreter. nasm is only needed by the x86 ones.
ifeq ($(BR2_aarch64),y)
LIBRETRO_MUPEN64PLUS_NEXT_DYNAREC = aarch64
else ifeq ($(BR2_arm),y)
LIBRETRO_MUPEN64PLUS_NEXT_DYNAREC = arm
else ifeq ($(BR2_x86_64),y)
LIBRETRO_MUPEN64PLUS_NEXT_DYNAREC = x86_64
LIBRETRO_MUPEN64PLUS_NEXT_DEPENDENCIES += host-nasm
else ifeq ($(BR2_i386),y)
LIBRETRO_MUPEN64PLUS_NEXT_DYNAREC = x86
LIBRETRO_MUPEN64PLUS_NEXT_DEPENDENCIES += host-nasm
endif

# FORCE_GLES3=1: GLideN64 for OpenGL ES 3 through EGL, linked with
# libGLESv2 and libEGL rather than the desktop libGL. The Vulkan
# renderer and its companions (paraLLEl-RDP, paraLLEl-RSP, the
# multithreaded Angrylion and the cxd4 LLE RSP) are left out: GLideN64
# with the HLE RSP is the only combination fast enough to be of use on
# the boards this is for.
LIBRETRO_MUPEN64PLUS_NEXT_MAKE_OPTS = \
	platform=unix \
	ARCH=$(BR2_ARCH) \
	WITH_DYNAREC=$(LIBRETRO_MUPEN64PLUS_NEXT_DYNAREC) \
	FORCE_GLES3=1 \
	HAVE_PARALLEL_RDP=0 \
	HAVE_PARALLEL_RSP=0 \
	HAVE_THR_AL=0 \
	LLE=0 \
	STRINGS="$(TARGET_CROSS)strings" \
	NASM="$(HOST_DIR)/bin/nasm" \
	GIT_VERSION='" $(shell printf %.7s $(LIBRETRO_MUPEN64PLUS_NEXT_VERSION))"'

# The flags go in through the environment, not the make command line:
# the Makefile appends its own to CFLAGS, CXXFLAGS and LDFLAGS.
#
# The EGL flags are the ones that keep <EGL/eglplatform.h> from pulling
# in the Xlib headers where the EGL provider needs to be told.
LIBRETRO_MUPEN64PLUS_NEXT_EGL_CFLAGS = \
	`$(PKG_CONFIG_HOST_BINARY) --cflags egl glesv2`

define LIBRETRO_MUPEN64PLUS_NEXT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(LIBRETRO_MUPEN64PLUS_NEXT_EGL_CFLAGS)" \
		CXXFLAGS="$(TARGET_CXXFLAGS) $(LIBRETRO_MUPEN64PLUS_NEXT_EGL_CFLAGS)" \
		$(MAKE) -C $(@D) -f Makefile \
		$(LIBRETRO_MUPEN64PLUS_NEXT_MAKE_OPTS)
endef

define LIBRETRO_MUPEN64PLUS_NEXT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/mupen64plus_next_libretro.so \
		$(TARGET_DIR)/usr/lib/libretro/mupen64plus_next_libretro.so
endef

$(eval $(generic-package))
