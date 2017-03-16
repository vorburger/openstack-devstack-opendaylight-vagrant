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

    nova flavor-list
    nova flavor-create m1.nano auto 64 0 1
    nova boot --image cirros-0.3.4-x86_64-uec --nic net-id=$(neutron net-list | awk "/n1/ {print \$2}") --flavor m1.nano vm1
    nova boot --image cirros-0.3.4-x86_64-uec --nic net-id=$(neutron net-list | awk "/n1/ {print \$2}") --flavor m1.nano vm2
    nova list
    sudo virsh list
    nova console-log vm1

Use web-based noVNC to get into vm1 & vm2:

    nova get-vnc-console vm1 novnc

_atkbd serio0: Use 'setkeycode 00 <keycode>' to make it known. Unknown key pressed_ is an issue with novnc that has been fixed but not in this version, so: `cd /opt/stack/noVNC; git checkout v0.6.0; cd -`.

If it just says `further output written to /dev/ttyS0` but then waits for a long time (minutes, not seconds) until the "login as 'cirros' user" login prompt appears, then your vm1/vm2 failed to obtain an IP from DHCP; as an `ipconfig` will prove, after you've finally been able to login when the prompt does ultimately appear.. You can try to `sudo ifdown eth0` (it will probably say `ifdown: interface eth0 not configured`) and `sudo ifup eth0`, but that will probably just "udhcp started" (`/sbin/cirros-dhcp up|down`) and try x3 to "Send discover" and then `No leave, failing` ...  see [ODL OpenStack Troubleshooting](http://docs.opendaylight.org/en/stable-boron/submodules/netvirt/docs/openstack-guide/openstack-with-netvirt.html#vm-dhcp-issues) re. how to debug the 10.11.12.0/24 network namespace. (... _TODO_ ...)  _Workaround: Do a complete restack when this happens (?)_;, **TODO better solution for this problem?**

If the noVNC screen is just black, then this typically 'just' means that the VM is not reachable, see Troubleshoot section below.


**PING**

Now, from the novnc console or SSH of `vm1`, make sure that you can successfully ping the IP of `vm2` (shown by `nova list`).


Undo
----

You can undo what you've done above using these commands:

    nova delete vm2
    nova delete vm1
    neutron subnet-delete s1
    neutron net-delete n1

_TODO test and confirm if this really works well, or document unstack os_reset.sh_


Topology
--------

* 192.168.150.10 is the OpenStack devstack VM, hostname "control"
* 192.168.150.1 is the host (your laptop / workstation), reachable from control
* 192.168.121.x vagrant-libvirt default???
* 192.168.122.1 virbr0 in BOTH control VM as well as host laptop - HUH?!


Troubleshoot
------------

Use `-v` for verbose output from all `nova`, `neutron` etc. commands; e.g. `neutron -v net-create n2`.  But NB that `-v` _"gives only the interaction with keystone"_, for more, see:

In [devstack](https://docs.openstack.org/developer/devstack/development.html), all services run as [screen](https://www.gnu.org/software/screen/manual/screen.html#Commands), so:

    vagrant ssh
    sudo su - stack
    screen -x stack

Detach with `Ctrl-a, d`; Next/Previous screen with `Ctrl-a, n/p` (NB `*` indicating current screen) - e.g. `q-svc` is Neutron Server, where log messages from the _neutron.plugins.ml2.managers_ re. _Mechanism driver 'opendaylight'_ show any ODL related problem.

Enter _scrolling (copy) mode_ with `Ctrl-a, [` - but beware, this will "lock up" (pause) processses, so you *MUST* exit scroll/copy mode by pressing `Enter` twice (or `Ctrl-a, ]`).

To debug the networking, compare the output of the following commands between a broken and a working environment, examples:

    $ sudo ovs-vsctl show
    Manager "tcp:192.168.150.1:6640"
        is_connected: true
    Bridge br-int
        Controller "tcp:192.168.150.1:6653"
            is_connected: true

    $ sudo ovs-ofctl -OOpenFlow13 show br-int
    It's OK to see DOWN here, this doesn't actually indicate a problem (TODO why?):
      config:     PORT_DOWN
      state:      LINK_DOWN

    $ sudo ovs-ofctl -OOpenFlow13 dump-flows br-int | head
     cookie=0x8000000, duration=100175.679s, table=0, n_packets=1351, n_bytes=130184, priority=4,in_port=1 actions=write_metadata:0x10000000000/0xffffff0000000001,goto_table:17
     cookie=0x8000000, duration=99996.114s, table=0, n_packets=176, n_bytes=14956, priority=4,in_port=2 actions=write_metadata:0x20000000000/0xffffff0000000001,goto_table:17
     cookie=0x8000000, duration=99679.741s, table=0, n_packets=143, n_bytes=13570, priority=4,in_port=3 actions=write_metadata:0x30000000000/0xffffff0000000001,goto_table:17

Make sure there are flows for table=0, and the n_packets and n_bytes counters actually show traffic, not just 0.  It's then interesting to watch a christmas of the flow hits light up on live traffic while you e.g. ping:

    watch -d "sudo ovs-ofctl -OOpenFlow13 dump-flows br-int"

If there is too much happening, or to zoom in to certain flows, it helps to use `grep` e.g. like this:

    watch -d "sudo ovs-ofctl -OOpenFlow13 dump-flows br-int | grep -o table=24.*"

an alternative (more suitable for low traffic) is to see the exact live action happening is to use `ovs-dpctl dump-flows` instead of `ovs-ofctl dump-flows` :

    while true; do echo ">>>>>"; sudo ovs-dpctl dump-flows; sleep 1; done

Using `ofproto/trace` is useful, as seen [ODL OpenStack Troubleshooting](http://docs.opendaylight.org/en/stable-boron/submodules/netvirt/docs/openstack-guide/openstack-with-netvirt.html#vm-dhcp-issues):

    sudo ovs-appctl ofproto/trace br-int ...

Here's how to check things on the OpenDaylight side:

    curl -u admin:admin http://localhost:8181/restconf/config/neutron:neutron/networks | python -mjson.tool
    curl -u admin:admin http://localhost:8181/restconf/config/ietf-interfaces:interfaces | python -mjson.tool
    curl -u admin:admin http://localhost:8181/restconf/operational/ietf-interfaces:interfaces-state | python -mjson.tool

You can also attempt to launch commands inside the network namespace, but it's normal that the following does NOT WORK, the flows prevent this traffic _(TODO why?):_

    ip netns
    qdhcp-...
    sudo ip netns exec qdhcp-... ping 10.11.12.x
    sudo ip netns exec qdhcp-... ssh cirros@10.11.12.x

but you CAN e.g. check `ifconfig`and `route` inside the network namespace, like this:

    $ sudo ip netns exec qdhcp-4d732098-0f04-4a39-8249-c7b48290ed7e ifconfig
    lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
    (...)
    tapd1ff9e96-3a: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1450
        inet 10.11.12.20  netmask 255.255.255.0  broadcast 10.11.12.255

    $ sudo ip netns exec qdhcp-... route
    Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
    default         gateway         0.0.0.0         UG    0      0        0 tapd1ff9e96-3a
    10.11.12.0      0.0.0.0         255.255.255.0   U     0      0        0 tapd1ff9e96-3a
    link-local      0.0.0.0         255.255.0.0     U     0      0        0 tapd1ff9e96-3a


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
