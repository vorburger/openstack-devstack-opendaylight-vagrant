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

# Huh? Sometimes it seems to use /opt/logs/stack and sometimes /opt/stack/logs/ ?!
mkdir -p /opt/logs/stack
chmod 777 /opt/logs/stack
mkdir -p /opt/stack/logs/
chmod 777 /opt/stack/logs/

# New user has home directory in /opt/stack (not /home), which script created
# so we move our devstack git clone there from the PWD, and fix permissions
mkdir /opt/stack/devstack/
mv {.[!.],}* /opt/stack/devstack/
cd ..
rmdir devstack

cp /vagrant/local.conf /opt/stack/devstack/local.conf

# This prevents a problem with "tempest", see https://gist.github.com/vorburger/3d08800f68672b7b483d43aeb774055b
# TODO How to do this "later" ?!?
## pip uninstall -y appdirs

# Now run stack.sh, but as our new user (~stack), not as the currently running ~root
sudo chown -R stack:stack /opt/stack/devstack/
sudo su - stack -c 'cd ~stack/devstack && ./stack.sh'

# When we're done, go to offline and no reclone, for faster future ./stack.sh after VM restart
sed -i -r -e 's/^#*\s*(OFFLINE=).*$/\1True/' local.conf
sed -i -r -e 's/^#*\s*(RECLONE=).*$/\1False/' local.conf

