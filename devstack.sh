#!/usr/bin/env bash

set -x
set -e errexit
# set -o pipefail

dnf upgrade -y

dnf install -y nano git qemu-kvm libvirt-client
# Ensure that hardware accelerated nested virtualization works
# TODO How to do this right...
# ls /dev/kvm
# cat /proc/cpuinfo | grep vmx
# /sbin/lsmod | grep kvm
virt-host-validate

# Disable SELinux on next reboot
echo "SELINUX=disabled" >/etc/selinux/config
echo "SELINUXTYPE=targeted" >>/etc/selinux/config
# Disable SELinux right now
setenforce 0
getenforce

# Fedora Cloud does not seem to have firewalld & iptables on by default anyway
# systemctl stop    firewalld
# systemctl disable firewalld
# systemctl stop    iptables.service
# systemctl disable iptables.service

mkdir -p /opt/stack
chmod 777 /opt/stack
mkdir /opt/stack/logs/
chmod 777 /opt/stack/logs/

git clone https://git.openstack.org/openstack-dev/devstack
cd devstack
git checkout stable/newton

# TODO later after basic devstack works..
# cp /vagrant/local.conf local.conf
#   TODO set HOST_IP to the IP of your VM
#   TODO set ODL_MGR_IP to the IP of where ODL will be running

./stack.sh

# git clone https://github.com/shague/odl_tools.git

