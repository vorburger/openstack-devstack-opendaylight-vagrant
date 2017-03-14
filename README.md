If you like/use this project, a Star / Watch / Follow me on GitHub is appreciated.


What?
=====

openstack-devstack-opendaylight-vagrant is a Vagrant-based utility
to create an OpenStack devstack environment virtual machine
(based on a Fedora Cloud base image) useful for development
of OpenDaylight.


How?
----

The very first time, one time install required Vagrant plugins:

    sudo dnf install zlib-devel libvirt-devel
    gem install nokogiri -v '1.6.8.1'
    vagrant plugin install vagrant-sshfs

If you are having any trouble with this, you can alternatively also just comment out the "synced_folder type: sshfs" in the Vagrantfile.  This (vagrant-sshfs) is only used to keep a .dnf-cache/ dir outside the VM, so that frequent vagrant up & vagrant destroy are faster.  So you can forget about it (by commenting out the use of sshfs), if you don't mind waiting a moment longer for the dnf in the VM.

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


local.conf changes
------------------

To tweak the OpenStack configuration, login to the VM, and in local.conf change the `RECLONE` from `True` to `False` (and `OFFLINE` from `False` to `True`, *unless* you're e.g. enabling a new service):

    vagrant ssh
    sudo su - stack
    cd /opt/stack/devstack

    nano local.conf
    ./unstack.sh
    ./stack.sh


Restart
-------

If your VM dies (or you have to `vagrant halt` it for some reason), then you have to restart OS procs by doing `./stack.sh` again, as above.  Make sure you have `RECLONE=False` and `OFFLINE=True`.  It's slow! :-(

You'll want to use `vagrant suspend` (NB the KVM qemu proc stays in memory!) and `vagrant resume` to save time re-stacking.

_TODO Figure out how to get "vagrant snapshot" working with KVM using https://github.com/miurahr/vagrant-kvm-snapshot, or switch to using VirtualBox instead of KVM?_



Usage
-----

    vagrant ssh
    sudo su - stack
    cd /opt/stack/devstack
    . openrc admin admin

    neutron net-create n1
    neutron subnet-create n1 --name s1 --allocation-pool start=10.11.12.20,end=10.11.12.30 10.11.12.0/24 
    nova boot --image cirros-0.3.4-x86_64-uec --nic net-id=$(neutron net-list | awk "/n1/ {print \$2}") --flavor m1.nano vm1
    nova boot --image cirros-0.3.4-x86_64-uec --nic net-id=$(neutron net-list | awk "/n1/ {print \$2}") --flavor m1.nano vm2
    nova list
    sudo virsh list
    nova console-log vm1
    nova get-vnc-console vm1 novnc

_atkbd serio0: Use 'setkeycode 00 <keycode>' to make it known. Unknown key pressed_ is an issue with novnc that has been fixed but not in this version, so: `cd /opt/stack/noVNC; git checkout v0.6.0; cd -`.

If it just says `further output written to /dev/ttyS0` but then waits for a long time (minutes, not seconds) until the "login as 'cirros' user" login prompt appears, then your vm1/vm2 failed to obtain an IP from DHCP; as an `ipconfig` will prove, after you've finally been able to login when the prompt does ultimately appear.. You can try to `sudo ifdown eth0` (it will probably say `ifdown: interface eth0 not configured`) and `sudo ifup eth0`, but that will probably just "udhcp started" (`/sbin/cirros-dhcp up|down`) and try x3 to "Send discover" and then `No leave, failing` ...  see [ODL OpenStack Troubleshooting](http://docs.opendaylight.org/en/stable-boron/submodules/netvirt/docs/openstack-guide/openstack-with-netvirt.html#vm-dhcp-issues) re. how to debug the 10.11.12.0/24 network namespace. (... _TODO_ ...)  _Workaround: Do a complete restack when this happens (?)_;, **TODO better solution for this problem?**

Now, from the novnc console of `vm1`, make sure that you can successfully ping the IP of `vm2` (shown by `nova list`).

You can undo what you've done above using these commands:

    nova delete vm2
    nova delete vm1
    neutron subnet-delete s1
    neutron net-delete n1


Topology
--------

* 192.168.150.10 is the OpenStack devstack VM, hostname "control"
* 192.168.150.1 is the host (your laptop / workstation), reachable from control


Troubleshoot
------------

Use `-v` for verbose output from all `nova`, `neutron` etc. commands; e.g. `neutron -v net-create n2`.  But NB that `-v` _"gives only the interaction with keystone"_, for more, see:

In [devstack](https://docs.openstack.org/developer/devstack/development.html), all services run as [screen](https://www.gnu.org/software/screen/manual/screen.html#Commands), so:

    vagrant ssh
    sudo su - stack
    screen -x stack

Detach with `Ctrl-a, d`; Next/Previous screen with `Ctrl-a, n/p` (NB `*` indicating current screen) - e.g. `q-svc` is Neutron Server, where log messages from the _neutron.plugins.ml2.managers_ re. _Mechanism driver 'opendaylight'_ show any ODL related problem.

Enter _scrolling (copy) mode_ with `Ctrl-a, [` - but beware, this will "lock up" (pause) processses, so you *MUST* exit scroll/copy mode by pressing `Enter` twice (or `Ctrl-a, ]`).


See also...
-----------

Background:

* http://docs.opendaylight.org/en/stable-boron/submodules/netvirt/docs/openstack-guide/openstack-with-netvirt.html#installing-openstack-and-opendaylight-using-devstack 
* https://docs.openstack.org/developer/devstack/networking.html
* https://docs.openstack.org/developer/devstack/guides/devstack-with-nested-kvm.html

For local OpenDaylight development:

* https://github.com/vorburger/opendaylight-eclipse-setup

Other similar OpenStack installer kind of projects:

* https://github.com/openstack-dev/devstack-vagrant/
* https://github.com/flavio-fernandes/devstack-nodes
* https://github.com/icclab/vagrant-devstack
* https://github.com/julienvey/devstack-vagrant/
* https://github.com/jhershberg/devstack-fedora-packer/blob/master/devstack-setup.sh
* https://github.com/dfarrell07/ansible-opendaylight
* https://github.com/opendaylight/integration-packaging/tree/master/docker/openstack/compute and more in opendaylight/integration-packaging
* https://git.opendaylight.org/gerrit/#/c/43880/
* OPNFV Apex installer
