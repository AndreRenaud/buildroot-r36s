################################################################################
#
# r36s-demo-app
#
################################################################################

R36S_DEMO_APP_VERSION = main
R36S_DEMO_APP_SITE = $(call github,AndreRenaud,r36s-demo-app,$(R36S_DEMO_APP_VERSION))

$(eval $(golang-package))
