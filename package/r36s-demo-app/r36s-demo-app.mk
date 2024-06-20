################################################################################
#
# r36s-demo-app
#
################################################################################

R36S_DEMO_APP_VERSION = main
R36S_DEMO_APP_SITE = $(call github,AndreRenaud,r36s-demo-app,$(R36S_DEMO_APP_VERSION))

R36S_DEMO_APP_DEPENDENCIES += sdl2_mixer sdl2_ttf sdl2_gfx

$(eval $(golang-package))
