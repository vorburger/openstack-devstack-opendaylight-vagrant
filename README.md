What?
=====

openstack-devstack-opendaylight-vagrant is a Vagrant-based utility
to create an OpenStack devstack environment virtual machine
(based on a Fedora Cloud base image) useful for development
of OpenDaylight.


How?
----

The very first time, one time install required Vagrant plugins (or comment out synced_folder type: sshfs in Vagrantfile):

    sudo dnf install zlib-devel libvirt-devel
    gem install nokogiri -v '1.6.8.1'
    vagrant plugin install vagrant-sshfs

Now get an OpenDaylight distribution on your host (not in the VM); either by DL a package, or build a local development env, for example:

    git clone https://git.opendaylight.org/gerrit/p/netvirt.git
    cd netvirt/vpnservice/distribution/karaf
    mvn clean package

And start OpenDaylight and install the (Karaf) feature `odl-netvirt-openstack` like this:

    cd target/assembly/bin
    ./karaf

    opendaylight-user@root>feature:install odl-netvirt-openstack

Test that OpenDaylight started and netvirt openstack is running e.g. with a `grep "StateManager all is ready" ../data/log/karaf.log` and no unexpected exceptions.

Now to provision and start the VM with OpenStack devstack, just:

    vagrant up

and that should finish, after quite a while, with a `DevStack Component Timing` message.  http://192.168.150.10/identity/ should return some JSON now.

The OpenStack /dashboard UI (Horizon) is now available on http://192.168.150.10/dashboard/ (unless de-activated by commenting `enable_service horizon` in local.conf, to save memory); login as admin/admin.


Topology
--------

* 192.168.150.10 is the OpenStack devstack VM, hostname "control"
* 192.168.150.1 is the host (your laptop / workstation), reachable from control


local.conf changes
------------------

To tweak the OpenStack configuration, login to the VM, and in local.conf change the `RECLONE` from `True` to `False` (and `OFFLINE` from `False` to `True`, *unless* you're e.g. enabling a new service:

    vagrant ssh
    sudo su - stack
    cd /opt/stack/devstack
    nano local.conf
    ./unstack.sh
    ./stack.sh


See also...
-----------

* http://docs.opendaylight.org/en/stable-boron/submodules/netvirt/docs/openstack-guide/openstack-with-netvirt.html#installing-openstack-and-opendaylight-using-devstack 
* https://github.com/dfarrell07/ansible-opendaylight
* https://github.com/opendaylight/integration-packaging/tree/master/docker/openstack/compute and more in opendaylight/integration-packaging
* https://git.opendaylight.org/gerrit/#/c/43880/
* OPNFV Apex installer
