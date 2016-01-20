#!/bin/bash

while [ $# -gt 0 ]; do
    case "$1" in
    --config)
            CONFIG_FILE="$2"
            shift
            ;;
    --image)
            IMAGE="$2"
            shift
            ;;
         *) break
            ;;
    esac
    shift
done

usage(){

cat << EOF

smart-channel-deploy.sh --config <smart-config-file> --image <live image>

EOF
}

verify_root_user()
{
    if [ "$EUID" -ne 0 ]; then
        return 1
    fi
    return 0
}

if ! [ -e "$CONFIG_FILE" ]; then
	usage
	exit 1
else
	CONFIG_FILE=`readlink -f $CONFIG_FILE`
fi

if ! [ -e "$IMAGE" ]; then
        usage
	exit 1
else
	IMAGE=`readlink -f $IMAGE`
fi

verify_root_user
if [ $? != 0 ]; then
	echo "root right is required to run this script!"
	exit 1
fi

device=`losetup -f --show $IMAGE`
partprobe ${device}
if [ -z "$device" ]; then
	echo "[ERROR]: No free loop devices available"
	exit 1
fi

if ! [ -e "${device}p3" ]; then
	echo "[ERROR]: ${device}p3 cannot available!"
	losetup -d ${device}
	exit 1
fi

if ! [ -e "${device}p4" ]; then
        echo "[ERROR]: ${device}p4 cannot available!"
	losetup -d ${device}
        exit 1
fi

if ! [ -e "/z" ]; then
	mkdir /z
fi

mount ${device}p3 /z
if [ -e "/z/rootfs/var/lib/lxc" ]; then
	mount ${device}p4 /z/rootfs/var/lib/lxc
	cd /z/rootfs
elif [ -e "/z/var/lib/lxc" ]; then
	mount ${device}p4 /z/var/lib/lxc
	cd /z
else
	echo "[ERROR]: essential rootfs is not available"
	umount /z
        losetup -d ${device}
fi

echo "[INFO] deploy $CONFIG_FILE to essential"
cp -f $CONFIG_FILE var/lib/smart/config

CN=`ls var/lib/lxc`

for cn in $CN; do
	if [ -d var/lib/lxc/$cn/rootfs/var/lib/smart ]; then
		echo "[INFO] deploy $CONFIG_FILE to $cn"
		cp -f $CONFIG_FILE var/lib/lxc/$cn/rootfs/var/lib/smart/config
	fi
done

echo "[INFO] clean up the system"
umount var/lib/lxc
cd - >/dev/null 2>&1
umount /z
losetup -d ${device}
