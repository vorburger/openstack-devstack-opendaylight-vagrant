# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Search for boxes at https://atlas.hashicorp.com/search.
  # Stick to Fedora Cloud v24 instead of 25, because devstack branch stable/newton else fails with:
  #    "WARNING: this script has not been tested on f25" (If you wish to run this script anyway run with FORCE=yes)
  config.vm.box = "fedora/24-cloud-base"
  # config.vm.box = "fedora/25-cloud-base"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.150.10" # TODO , :netmask => "255.255.255.0"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  config.vm.host_name = "control"

  config.vm.provider :libvirt do |libvirt|
        libvirt.cpus = 2
        libvirt.memory = 4096
        # libvirt.graphics_type = "spice"
        # libvirt.video_type = "qxl"
  end

  # UNTESTED
  # config.vm.provider :virtualbox do |vb|
  # config.vm.provider "virtualbox" do |vb|
  #      # Display the VirtualBox GUI when booting the machine
  #      vb.gui = true
  #      # Customize the amount of memory on the VM:
  #      vb.memory = "4096"
  #      # Use VBoxManage to customize the VM. For example to change memory:
  #      vb.customize ["modifyvm", :id, "--memory", "4096"]
  #      vb.customize ["modifyvm", :id, "--cpus", "2"]
  #      # you need this for openstack guests to talk to each other
  #      vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
  # end

  # Cache RPM packages (helpful if frequently doing `vagrant destroy && vagrant up`)
  # This requires https://github.com/dustymabe/vagrant-sshfs#install-plugin, which is a minor PITA to install
  # (https://github.com/fgrehm/vagrant-cachier is a another more complete and complex solution; this is simple enough and works for us)
  config.vm.synced_folder ".dnf-cache", "/var/cache/dnf", type: "sshfs", sshfs_opts_append: "-o nonempty"

  # Make sure the default /vagrant sync doesn't copy the (big) .dnf-cache/ into the VM
  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", ".dnf-cache/" ]

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available.
  # NB shell already 
  config.vm.provision "shell", path: "devstack.sh"

  config.ssh.forward_agent = true

end
