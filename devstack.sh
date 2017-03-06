#!/usr/bin/env bash

set -x
set -e errexit
# set -o pipefail

dnf upgrade -y

dnf install -y nano git qemu-kvm libvirt-client
# Ensure that hardware accelerated nested virtualization works
# TODO How to do this right...
ls /dev/kvm
cat /proc/cpuinfo | grep vmx
/sbin/lsmod | grep kvm
# Fails even if it's just a WARN for "QEMU: Checking for device assignment IOMMU support" :-(
# virt-host-validate

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

git clone https://git.openstack.org/openstack-dev/devstack
cd devstack
git checkout stable/newton
cp samples/local.conf local.conf

# This script creates a new ~stack user
./tools/create-stack-user.sh
mkdir /opt/stack/logs/
chmod 777 /opt/stack/logs/

# New user has home directory in /opt/stack (not /home), which script created
# so we move our devstack git clone there from the PWD, and fix permissions
mkdir /opt/stack/devstack/
mv {.[!.],}* /opt/stack/devstack/
cd ..
rmdir devstack
sudo chown -R stack:stack /opt/stack/devstack/

# TODO later after basic devstack works..
# cp /vagrant/local.conf local.conf
#   TODO set HOST_IP to the IP of your VM
#   TODO set ODL_MGR_IP to the IP of where ODL will be running

# Now run stack.sh, but as our new user (~stack), not as the currently running ~root
sudo su - stack -c 'cd ~stack/devstack && ./stack.sh'

