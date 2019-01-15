# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.0.1"

VAGRANTROOT = File.expand_path(File.dirname(__FILE__))
VAGRANTFILE_API_VERSION = "2"

# Ensure vagrant plugins
required_plugins = %w( vagrant-vbguest vagrant-scp vagrant-share vagrant-persistent-storage vagrant-reload )

required_plugins.each do |plugin|
  exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "control" do |control|

    IPADDR = "172.99.36.254"
    CPUS = "1"
    MEMORY = "1024"
    MULTIVOL = false
    MOUNTPOINT = "/mnt"

    control.vm.box = "centos/7"
    config.ssh.insert_key = false
    control.vm.network :private_network, ip: IPADDR,
      virtualbox__hostonly: true

    control.vm.provider :virtualbox do |vb|
      vb.name = "control"
      vb.memory = MEMORY
      vb.cpus = CPUS
      if CPUS != "1"
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
      end
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.linked_clone = true if Vagrant::VERSION =~ /^1.8/
    end

    control.vm.hostname = "control.lab.example.com"
    control.vm.provision :shell, inline: "yum -y install ansible"
    control.vm.provision "file",
      source: "~/.gitconfig",
      destination: ".gitconfig"
    control.vm.provision :shell, inline: "yum -y update"

    # Install git and wget
    control.vm.provision :shell, inline: "yum -y install git wget"
    # Load bashrc
    control.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "${HOME}/.bashrc"
    control.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "/home/vagrant/.bashrc"

    # Load ssh keys
    control.vm.provision "file", source: "#{VAGRANTROOT}/files/vagrant",
      destination: "/home/vagrant/.ssh/id_rsa"
    control.vm.provision :shell, inline: "chmod 600 /home/vagrant/.ssh/id_rsa"
    control.vm.provision :file, source: "#{VAGRANTROOT}/files/vagrant.pub",
      destination: "/home/vagrant/.ssh/id_rsa.pub"

    # Load /etc/hosts
    #control.vm.provision "shell", path: "./bin/hosts.sh", privileged: true
    control.vm.provision "file", source: "#{VAGRANTROOT}/files/hosts",
      destination: "/tmp/hosts"
    control.vm.provision :shell, inline: "mv -f /tmp/hosts /etc/hosts"

    # Load ansible config to ~vagrant on the guest
    control.vm.provision "file",
      source: "#{VAGRANTROOT}/ansible/ansible.cfg",
      destination: "~vagrant/ansible.cfg"

    control.vm.provision "file",
      source: "#{VAGRANTROOT}/ansible/OSEv3.yml",
      destination: "~vagrant/inventory"

    # Run ansible provisioning
    control.vm.provision :ansible do |ansible|
      ansible.verbose = "v"
      ansible.config_file = "#{VAGRANTROOT}/ansible/ansible.cfg"
      ansible.galaxy_roles_path  = "#{VAGRANTROOT}/ansible/roles"
      ansible.galaxy_role_file = "#{VAGRANTROOT}/ansible/requirements.yml"
      ansible.galaxy_command = "ansible-galaxy install --role-file=./ansible/requirements.yml --roles-path=./ansible/roles --force"
      ansible.playbook = "#{VAGRANTROOT}/ansible/playbooks/control.yml"
    end
  end #!- control

  config.vm.define "master" do |master|

    $IPADDR = "172.99.36.5"
    $CPUS = "2"
    $MEMORY = "6144"
    $MULTIVOL = false
    $MOUNTPOINT = "/mnt"

    master.vm.box = "centos/7"
    config.ssh.insert_key = false
    master.vm.network :private_network, ip: $IPADDR,
      virtualbox__hostonly: true
    master.vm.network :forwarded_port, guest: 8443, host: 8443,
      virtualbox__hostonly: true

    master.vm.provider :virtualbox do |vb|
      vb.name = "master"
      vb.memory = $MEMORY
      vb.cpus = $CPUS
      if $CPUS != "1"
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
      end
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.linked_clone = true if Vagrant::VERSION =~ /^1.8/
    end

    master.vm.hostname = "master.lab.example.com"
    #master.vm.provision :shell, inline: "yum -y install ansible"
    master.vm.provision :shell, inline: "yum -y install https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.9-1.el7.ans.noarch.rpm"
    master.vm.provision "file",
      source: "~/.gitconfig",
      destination: ".gitconfig"

    master.vm.provision :shell, inline: "yum -y update"

    # Install git and wget
    master.vm.provision :shell, inline: "yum -y install git wget"
    # Load bashrc
    master.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "${HOME}/.bashrc"
    master.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "/home/vagrant/.bashrc"

    # Load ssh keys
    master.vm.provision "file", source: "#{VAGRANTROOT}/files/vagrant",
      destination: "/home/vagrant/.ssh/id_rsa"
    master.vm.provision :shell, inline: "chmod 600 /home/vagrant/.ssh/id_rsa"
    master.vm.provision :file, source: "#{VAGRANTROOT}/files/vagrant.pub",
    destination: "/home/vagrant/.ssh/id_rsa.pub"

    # Load /etc/hosts
    #master.vm.provision "shell", path: "./bin/hosts.sh", privileged: true
    master.vm.provision "file", source: "#{VAGRANTROOT}/files/hosts",
      destination: "/tmp/hosts"
    master.vm.provision :shell, inline: "mv -f /tmp/hosts /etc/hosts"

    # Run ansible provisioning
    master.vm.provision :ansible do |ansible|
      ansible.verbose = "v"
      ansible.config_file = "#{VAGRANTROOT}/ansible/ansible.cfg"
      ansible.galaxy_roles_path  = "#{VAGRANTROOT}/ansible/roles"
      ansible.galaxy_role_file = "#{VAGRANTROOT}/ansible/requirements.yml"
      ansible.galaxy_command = "ansible-galaxy install --role-file=./ansible/requirements.yml --roles-path=./ansible/roles --force"
      ansible.playbook = "#{VAGRANTROOT}/ansible/playbooks/master.yml"
    end
  end #!- master

  config.vm.define "infra1" do |infra1|

    $IPADDR = "172.99.36.6"
    $CPUS = "2"
    $MEMORY = "2048"
    $MULTIVOL = false
    $MOUNTPOINT = "/mnt"

    infra1.vm.box = "centos/7"
    config.ssh.insert_key = false
    infra1.vm.network :private_network, ip: $IPADDR,
      virtualbox__hostonly: true

    infra1.vm.provider :virtualbox do |vb|
      vb.name = "infra1"
      vb.memory = $MEMORY
      vb.cpus = $CPUS
      if $CPUS != "1"
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
      end
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.linked_clone = true if Vagrant::VERSION =~ /^1.8/
    end

    infra1.vm.hostname = "infra1.lab.example.com"
    infra1.vm.provision "file",
      source: "~/.gitconfig",
      destination: ".gitconfig"

    infra1.vm.provision :shell, inline: "yum -y update"

    # Install git and wget
    infra1.vm.provision :shell, inline: "yum -y install git wget"
    # Load bashrc
    infra1.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "${HOME}/.bashrc"
    infra1.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "/home/vagrant/.bashrc"

    # Load ssh keys
    infra1.vm.provision "file", source: "#{VAGRANTROOT}/files/vagrant",
      destination: "/home/vagrant/.ssh/id_rsa"
    infra1.vm.provision :shell, inline: "chmod 600 /home/vagrant/.ssh/id_rsa"
    infra1.vm.provision :file, source: "#{VAGRANTROOT}/files/vagrant.pub",
      destination: "/home/vagrant/.ssh/id_rsa.pub"

    # Load /etc/hosts
    infra1.vm.provision "file", source: "#{VAGRANTROOT}/files/hosts",
      destination: "/tmp/hosts"
    infra1.vm.provision :shell, inline: "mv -f /tmp/hosts /etc/hosts"

    # Run ansible provisioning
    infra1.vm.provision :ansible do |ansible|
      ansible.verbose = "v"
      ansible.config_file = "#{VAGRANTROOT}/ansible/ansible.cfg"
      ansible.galaxy_roles_path  = "#{VAGRANTROOT}/ansible/roles"
      ansible.galaxy_role_file = "#{VAGRANTROOT}/ansible/requirements.yml"
      ansible.galaxy_command = "ansible-galaxy install --role-file=./ansible/requirements.yml --roles-path=./ansible/roles --force"
      ansible.playbook = "#{VAGRANTROOT}/ansible/playbooks/infra1.yml"
    end
  end #!- infra1

config.vm.define "node1" do |node1|

  $IPADDR = "172.99.36.7"
  $CPUS = "2"
  $MEMORY = "4096"
  $MULTIVOL = false
  $MOUNTPOINT = "/mnt"

    node1.vm.box = "centos/7"
    config.ssh.insert_key = false
    node1.vm.network :private_network, ip: $IPADDR,
      virtualbox__hostonly: true

    node1.vm.provider :virtualbox do |vb|
      vb.name = "node1"
      vb.memory = $MEMORY
      vb.cpus = $CPUS
      if $CPUS != "1"
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
      end
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.linked_clone = true if Vagrant::VERSION =~ /^1.8/
    end

    node1.vm.hostname = "node1.lab.example.com"
    node1.vm.provision :shell, inline: "yum -y install ansible"
    node1.vm.provision "file",
      source: "~/.gitconfig",
      destination: ".gitconfig"

    node1.vm.provision :shell, inline: "yum -y update"

    # Install git and wget
    node1.vm.provision :shell, inline: "yum -y install git wget"
    # Load bashrc
    node1.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "${HOME}/.bashrc"
    node1.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "/home/vagrant/.bashrc"

    # Load ssh keys
    node1.vm.provision "file", source: "#{VAGRANTROOT}/files/vagrant",
      destination: "/home/vagrant/.ssh/id_rsa"
    node1.vm.provision :shell, inline: "chmod 600 /home/vagrant/.ssh/id_rsa"
    node1.vm.provision :file, source: "#{VAGRANTROOT}/files/vagrant.pub",
      destination: "/home/vagrant/.ssh/id_rsa.pub"

    # Load /etc/hosts
    node1.vm.provision "file", source: "#{VAGRANTROOT}/files/hosts",
      destination: "/tmp/hosts"
    node1.vm.provision :shell, inline: "mv -f /tmp/hosts /etc/hosts"

    # Run ansible provisioning
    node1.vm.provision :ansible do |ansible|
      ansible.verbose = "v"
      ansible.config_file = "#{VAGRANTROOT}/ansible/ansible.cfg"
      ansible.galaxy_roles_path  = "#{VAGRANTROOT}/ansible/roles"
      ansible.galaxy_role_file = "#{VAGRANTROOT}/ansible/requirements.yml"
      ansible.galaxy_command = "ansible-galaxy install --role-file=./ansible/requirements.yml --roles-path=./ansible/roles --force"
      ansible.playbook = "#{VAGRANTROOT}/ansible/playbooks/node1.yml"
    end
  end #!- node0

config.vm.define "node2" do |node2|

  $IPADDR = "172.99.36.8"
  $CPUS = "2"
  $MEMORY = "4096"
  $MULTIVOL = false
  $MOUNTPOINT = "/mnt"

    node2.vm.box = "centos/7"
    config.ssh.insert_key = false
    node2.vm.network :private_network, ip: $IPADDR,
      virtualbox__hostonly: true

    node2.vm.provider :virtualbox do |vb|
      vb.name = "node2"
      vb.memory = $MEMORY
      vb.cpus = $CPUS
      if $CPUS != "1"
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
      end
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.linked_clone = true if Vagrant::VERSION =~ /^1.8/
    end

    node2.vm.hostname = "node2.lab.example.com"
    node2.vm.provision :shell, inline: "yum -y install ansible"
    node2.vm.provision "file",
      source: "~/.gitconfig",
      destination: ".gitconfig"

    node2.vm.provision :shell, inline: "yum -y update"

    # Install git and wget
    node2.vm.provision :shell, inline: "yum -y install git wget"
    # Load bashrc
    node2.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "${HOME}/.bashrc"
    node2.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "/home/vagrant/.bashrc"

    # Load ssh keys
    node2.vm.provision "file", source: "#{VAGRANTROOT}/files/vagrant",
      destination: "/home/vagrant/.ssh/id_rsa"
    node2.vm.provision :shell, inline: "chmod 600 /home/vagrant/.ssh/id_rsa"
    node2.vm.provision :file, source: "#{VAGRANTROOT}/files/vagrant.pub",
      destination: "/home/vagrant/.ssh/id_rsa.pub"

    # Load /etc/hosts
    node2.vm.provision "file", source: "#{VAGRANTROOT}/files/hosts",
      destination: "/tmp/hosts"
    node2.vm.provision :shell, inline: "mv -f /tmp/hosts /etc/hosts"

    # Run ansible provisioning
    node2.vm.provision :ansible do |ansible|
      ansible.verbose = "v"
      ansible.config_file = "#{VAGRANTROOT}/ansible/ansible.cfg"
      ansible.galaxy_roles_path  = "#{VAGRANTROOT}/ansible/roles"
      ansible.galaxy_role_file = "#{VAGRANTROOT}/ansible/requirements.yml"
      ansible.galaxy_command = "ansible-galaxy install --role-file=./ansible/requirements.yml --roles-path=./ansible/roles --force"
      ansible.playbook = "#{VAGRANTROOT}/ansible/playbooks/node2.yml"
    end
  end #!- node2

end
