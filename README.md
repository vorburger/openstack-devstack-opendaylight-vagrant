What?
=====

openstack-devstack-opendaylight-vagrant is a Vagrant-based utility
to create an OpenStack devstack environment virtual machine
(based on a Fedora Cloud base image) useful for development
of OpenDaylight.


How?
----

    sudo dnf install zlib-devel libvirt-devel
    gem install nokogiri -v '1.6.8.1'
    vagrant plugin install vagrant-sshfs

    vagrant up
