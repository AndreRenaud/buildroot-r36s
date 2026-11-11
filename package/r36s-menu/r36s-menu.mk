################################################################################
#
# r36s-menu
#
################################################################################

R36S_MENU_VERSION = 46c3cc08f8a0aa00460bc2ae5aa2bc1a5d6099fb
R36S_MENU_SITE = $(call github,AndreRenaud,r36s-menu,$(R36S_MENU_VERSION))
R36S_MENU_LICENSE = OFL-1.1 (fonts)
R36S_MENU_LICENSE_FILES = assets/OFL-Caveat.txt assets/OFL-Nunito.txt
R36S_MENU_GOMOD = github.com/AndreRenaud/r36s-menu

# Loaded with dlopen() at run time, not linked
R36S_MENU_DEPENDENCIES = libdrm libegl libgbm libgles

$(eval $(golang-package))
