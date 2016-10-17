source config-usb.sh

CONFIG_DIRS=`dirname $BASH_SOURCE`

HDINSTALL_ROOTFS="${ARTIFACTS_DIR}/cube-essential-intel-corei7-64.tar.bz2"

HDINSTALL_CONTAINERS="${ARTIFACTS_DIR}/cube-dom0-intel-corei7-64.tar.bz2:console:vty=2:mergepath=/usr,essential \
                      ${ARTIFACTS_DIR}/cube-gw-intel-corei7-64.tar.bz2:monitored:privileged:console:vty=3,active:net=1:mergepath=/usr,essential,dom0 \
		      "
NETWORK_DEVICE_CLASSES="eth* wl* en*"
NETWORK_DEVICE="eth0"

INSTALL_ROOTFS="${ARTIFACTS_DIR}/cube-essential-intel-corei7-64.tar.bz2"

