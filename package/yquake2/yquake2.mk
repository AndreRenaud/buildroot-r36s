################################################################################
#
# yquake2
#
################################################################################

YQUAKE2_VERSION = 8.70
YQUAKE2_SOURCE = quake2-$(YQUAKE2_VERSION).tar.xz
YQUAKE2_SITE = https://deponie.yamagi.org/quake2
YQUAKE2_LICENSE = GPL-2.0+, Info-ZIP, Zlib, MIT, MIT or Unlicense, Apache-2.0
YQUAKE2_LICENSE_FILES = LICENSE
YQUAKE2_DEPENDENCIES = sdl3

YQUAKE2_DATADIR = /usr/share/games/quake2

# The upstream Makefile detects the architecture with uname -m and
# defaults to the host's /usr/include and /usr/lib, so override all of
# that. The architecture name is normalised the way upstream does it.
YQUAKE2_MAKE_OPTS = \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	INCLUDE= \
	PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" \
	YQ2_OSTYPE=Linux \
	YQ2_ARCH=$(shell echo $(call qstrip,$(BR2_ARCH)) | sed -e 's/i.86/i386/' -e 's/^arm.*/arm/') \
	WITH_RPATH=no \
	WITH_SDL3=yes \
	WITH_SYSTEMWIDE=yes \
	WITH_SYSTEMDIR=$(YQUAKE2_DATADIR)

# Both are loaded with dlopen() at runtime, but need their headers to
# build.
ifeq ($(BR2_PACKAGE_LIBCURL),y)
YQUAKE2_DEPENDENCIES += libcurl
YQUAKE2_MAKE_OPTS += WITH_CURL=yes
else
YQUAKE2_MAKE_OPTS += WITH_CURL=no
endif

ifeq ($(BR2_PACKAGE_OPENAL),y)
YQUAKE2_DEPENDENCIES += openal
YQUAKE2_MAKE_OPTS += WITH_OPENAL=yes
else
YQUAKE2_MAKE_OPTS += WITH_OPENAL=no
endif

ifeq ($(BR2_TOOLCHAIN_USES_GLIBC),y)
YQUAKE2_MAKE_OPTS += WITH_EXECINFO=yes
else
YQUAKE2_MAKE_OPTS += WITH_EXECINFO=no
endif

ifeq ($(BR2_PACKAGE_YQUAKE2_DEMO_DATA),y)
YQUAKE2_DEMO_SOURCE = q2-314-demo-x86.exe
YQUAKE2_EXTRA_DOWNLOADS = \
	https://deponie.yamagi.org/quake2/idstuff/$(YQUAKE2_DEMO_SOURCE)
YQUAKE2_LICENSE += , Quake II demo licence (demo data)
YQUAKE2_LICENSE_FILES += demo/Install/Data/DOCS/license.txt

# The demo is a self-extracting ZIP archive.
define YQUAKE2_EXTRACT_DEMO_DATA
	$(UNZIP) -o -d $(@D)/demo $(YQUAKE2_DL_DIR)/$(YQUAKE2_DEMO_SOURCE) \
		'Install/Data/baseq2/pak0.pak' \
		'Install/Data/baseq2/players/*' \
		'Install/Data/DOCS/license.txt'
endef
YQUAKE2_POST_EXTRACT_HOOKS += YQUAKE2_EXTRACT_DEMO_DATA

define YQUAKE2_INSTALL_DEMO_DATA
	$(INSTALL) -D -m 0644 $(@D)/demo/Install/Data/baseq2/pak0.pak \
		$(TARGET_DIR)$(YQUAKE2_DATADIR)/baseq2/pak0.pak
	cp -dpfr $(@D)/demo/Install/Data/baseq2/players \
		$(TARGET_DIR)$(YQUAKE2_DATADIR)/baseq2/
	$(INSTALL) -D -m 0644 $(@D)/demo/Install/Data/DOCS/license.txt \
		$(TARGET_DIR)$(YQUAKE2_DATADIR)/demo-license.txt
endef
endif

define YQUAKE2_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(YQUAKE2_MAKE_OPTS) \
		client game ref_gles3
endef

# Upstream wants the executable, the renderers and baseq2/game.so kept
# together in one directory; the executable can be symlinked elsewhere.
define YQUAKE2_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/release/quake2 \
		$(TARGET_DIR)/usr/lib/yquake2/quake2
	$(INSTALL) -D -m 0755 $(@D)/release/ref_gles3.so \
		$(TARGET_DIR)/usr/lib/yquake2/ref_gles3.so
	$(INSTALL) -D -m 0755 $(@D)/release/baseq2/game.so \
		$(TARGET_DIR)/usr/lib/yquake2/baseq2/game.so
	mkdir -p $(TARGET_DIR)/usr/bin
	ln -sf ../lib/yquake2/quake2 $(TARGET_DIR)/usr/bin/quake2
	$(YQUAKE2_INSTALL_DEMO_DATA)
endef

$(eval $(generic-package))
