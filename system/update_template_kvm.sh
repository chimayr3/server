#!/usr/bin/env bash

if [ "${#}" -ne 2 ]; then
        echo "Usage: ${0} <hostname> <ip en 10.0.0.xxx>"
        exit 1
fi

host_name="${1}"
IP="${2}"

# configure network interface
rm -f /etc/udev/rules.d/70-persistent-net.rules 2>/dev/null

echo "DEVICE=eth0
TYPE=Ethernet
IPADDR=${IP}
NETMASK=255.255.255.0
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=static" > /etc/sysconfig/network-scripts/ifcfg-eth0

echo "default via 10.0.0.1 dev eth0" > /etc/sysconfig/network-scripts/route-eth0

# set hostname
sed -i s/HOSTNAME=[a-z]*/HOSTNAME=${host_name}/ /etc/sysconfig/network
hostname ${host_name}
exit 0
