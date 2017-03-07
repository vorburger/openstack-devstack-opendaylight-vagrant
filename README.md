What?
=====

openstack-devstack-opendaylight-vagrant is a Vagrant-based utility
to create an OpenStack devstack environment virtual machine
(based on a Fedora Cloud base image) useful for development
of OpenDaylight.


How?
----

The very first time:

    sudo dnf install zlib-devel libvirt-devel
    gem install nokogiri -v '1.6.8.1'
    vagrant plugin install vagrant-sshfs

Every time:

    vagrant up


See also...
-----------

* http://docs.opendaylight.org/en/stable-boron/submodules/netvirt/docs/openstack-guide/openstack-with-netvirt.html#installing-openstack-and-opendaylight-using-devstack 
* https://github.com/dfarrell07/ansible-opendaylight
* https://github.com/opendaylight/integration-packaging/tree/master/docker/openstack/compute and more in opendaylight/integration-packaging
* https://git.opendaylight.org/gerrit/#/c/43880/
* OPNFV Apex installer
