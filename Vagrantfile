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
    control.vm.network :forwarded_port, guest: 80, host: 10080,
      virtualbox__hostonly: true
    control.vm.network :forwarded_port, guest: 443, host: 10443,
      virtualbox__hostonly: true
    control.vm.network :forwarded_port, guest: 8052, host: 10052,
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

    control.vm.hostname = "control.local"
    control.vm.provision :shell, inline: "yum -y install ansible"
    control.vm.provision "file",
      source: "~/.gitconfig",
      destination: ".gitconfig"

    # Disable selinux and reboot
    unless FileTest.exist?("./untracked-files/first_boot_complete_control")
      control.vm.provision :shell, inline: "yum -y update"
      control.vm.provision :shell, inline: "sed -i s/^SELINUX=enforcing/SELINUX=permissive/ /etc/selinux/config"
      control.vm.provision :reload
      #control.vm.synced_folder ".", "/vagrant"
      require 'fileutils'
      FileUtils.touch("#{VAGRANTROOT}/untracked-files/first_boot_complete_control")
    end

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
    control.vm.provision "shell", path: "./bin/hosts.sh", privileged: true

    # Set ansible roles environment variable
    # This is unused and may be set wrong, i.e. as currently
    # configured it addresses the host context but it probably should
    # be the guest context, like the following
    #  ENV['ANSIBLE_ROLES_PATH'] = "#{VAGRANTROOT}/ansible/roles"
    #ENV['ANSIBLE_ROLES_PATH'] = "~vagrant/ansible/roles"

    # Load ansible config to ~vagrant on the guest
    control.vm.provision "file",
      source: "#{VAGRANTROOT}/ansible/ansible.cfg",
      destination: "~vagrant/ansible.cfg"

    control.vm.provision "file",
      source: "#{VAGRANTROOT}/ansible/inventory",
      destination: "~vagrant/inventory"

    control.vm.provision "file",
      source: "#{VAGRANTROOT}/ansible/requirements.yml",
      destination: "~vagrant/requirements.yml"

    control.vm.provision "shell", inline: "[[ -d ~vagrant/playbooks ]] || \
      mkdir ~vagrant/playbooks/ && chown vagrant: ~vagrant/playbooks"

    control.vm.provision "file",
      source: "#{VAGRANTROOT}/ansible/playbooks/control.yml",
      destination: "~vagrant/playbooks/control.yml"

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

  #$HOSTNAME = "master"
  #$ANSIBLEROLE = $HOSTNAME
  #$ANSIBLEROLE = "master"
  $IPADDR = "172.99.36.6"
  $CPUS = "2"
  $MEMORY = "2048"
  $MULTIVOL = false
  $MOUNTPOINT = "/mnt"

    master.vm.box = "centos/7"
    config.ssh.insert_key = false
    master.vm.network :private_network, ip: $IPADDR,
      virtualbox__hostonly: true
    master.vm.network :forwarded_port, guest: 80, host: 6080,
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

    master.vm.hostname = "master.local"
    master.vm.provision :shell, inline: "yum -y install ansible"
    master.vm.provision "file",
      source: "~/.gitconfig",
      destination: ".gitconfig"

    master.vm.provision :shell, inline: "yum -y update"

    ## Disable selinux and reboot
    #unless FileTest.exist?("./untracked-files/first_boot_complete")
    #  master.vm.provision :shell, inline: "sed -i s/^SELINUX=enforcing/SELINUX=permissive/ /etc/selinux/config"
    #  master.vm.provision :reload
    #  require 'fileutils'
    #  FileUtils.touch("#{VAGRANTROOT}/untracked-files/first_boot_complete")
    #end

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
    master.vm.provision "shell", path: "./bin/hosts.sh", privileged: true

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

config.vm.define "appnode0" do |appnode0|

  $IPADDR = "172.99.36.7"
  $CPUS = "2"
  $MEMORY = "2048"
  $MULTIVOL = false
  $MOUNTPOINT = "/mnt"

    appnode0.vm.box = "centos/7"
    config.ssh.insert_key = false
    appnode0.vm.network :private_network, ip: $IPADDR,
      virtualbox__hostonly: true
    appnode0.vm.network :forwarded_port, guest: 80, host: 7080,
      virtualbox__hostonly: true

    appnode0.vm.provider :virtualbox do |vb|
      vb.name = "appnode0"
      vb.memory = $MEMORY
      vb.cpus = $CPUS
      if $CPUS != "1"
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
      end
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.linked_clone = true if Vagrant::VERSION =~ /^1.8/
    end

    appnode0.vm.hostname = "appnode0.local"
    appnode0.vm.provision :shell, inline: "yum -y install ansible"
    appnode0.vm.provision "file",
      source: "~/.gitconfig",
      destination: ".gitconfig"

    ## Disable selinux and reboot
    #unless FileTest.exist?("./untracked-files/first_boot_complete")
    #  appnode0.vm.provision :shell, inline: "yum -y update"
    #  appnode0.vm.provision :shell, inline: "sed -i s/^SELINUX=enforcing/SELINUX=permissive/ /etc/selinux/config"
    #  appnode0.vm.provision :reload
    #  #master.vm.synced_folder ".", "/vagrant"
    #  require 'fileutils'
    #  FileUtils.touch("#{VAGRANTROOT}/untracked-files/first_boot_complete")
    #end

    # Install git and wget
    appnode0.vm.provision :shell, inline: "yum -y install git wget"
    # Load bashrc
    appnode0.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "${HOME}/.bashrc"
    appnode0.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "/home/vagrant/.bashrc"

    # Load ssh keys
    appnode0.vm.provision "file", source: "#{VAGRANTROOT}/files/vagrant",
      destination: "/home/vagrant/.ssh/id_rsa"
    appnode0.vm.provision :shell, inline: "chmod 600 /home/vagrant/.ssh/id_rsa"
    appnode0.vm.provision :file, source: "#{VAGRANTROOT}/files/vagrant.pub",
      destination: "/home/vagrant/.ssh/id_rsa.pub"

    # Load /etc/hosts
    appnode0.vm.provision "shell", path: "./bin/hosts.sh", privileged: true

    # Load ansible config to ~vagrant on the guest
    #appnode0.vm.provision "file",
    #  source: "#{VAGRANTROOT}/ansible/ansible.cfg",
    #  destination: "~vagrant/ansible.cfg"

    #appnode0.vm.provision "file",
    #  source: "#{VAGRANTROOT}/ansible/inventory",
    #  destination: "~vagrant/inventory"

    #appnode0.vm.provision "file",
    #  source: "#{VAGRANTROOT}/ansible/requirements.yml",
    #  destination: "~vagrant/requirements.yml"

    #appnode0.vm.provision "shell", inline: "[[ -d ~vagrant/playbooks ]] || \
    #  mkdir ~vagrant/playbooks/ && chown vagrant: ~vagrant/playbooks"

    #appnode0.vm.provision "file",
    #  source: "#{VAGRANTROOT}/ansible/playbooks/appnode0.yml",
    #  destination: "~vagrant/playbooks/appnode0.yml"

    # Run ansible provisioning
    appnode0.vm.provision :ansible do |ansible|
      ansible.verbose = "v"
      ansible.config_file = "#{VAGRANTROOT}/ansible/ansible.cfg"
      ansible.galaxy_roles_path  = "#{VAGRANTROOT}/ansible/roles"
      ansible.galaxy_role_file = "#{VAGRANTROOT}/ansible/requirements.yml"
      ansible.galaxy_command = "ansible-galaxy install --role-file=./ansible/requirements.yml --roles-path=./ansible/roles --force"
      ansible.playbook = "#{VAGRANTROOT}/ansible/playbooks/appnode0.yml"
    end
  end #!- appnode0

config.vm.define "appnode1" do |appnode1|

  $IPADDR = "172.99.36.7"
  $CPUS = "2"
  $MEMORY = "2048"
  $MULTIVOL = false
  $MOUNTPOINT = "/mnt"

    appnode1.vm.box = "centos/7"
    config.ssh.insert_key = false
    appnode1.vm.network :private_network, ip: $IPADDR,
      virtualbox__hostonly: true
    appnode1.vm.network :forwarded_port, guest: 80, host: 8080,
      virtualbox__hostonly: true

    appnode1.vm.provider :virtualbox do |vb|
      vb.name = "appnode1"
      vb.memory = $MEMORY
      vb.cpus = $CPUS
      if $CPUS != "1"
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
      end
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.linked_clone = true if Vagrant::VERSION =~ /^1.8/
    end

    appnode1.vm.hostname = "appnode1.local"
    appnode1.vm.provision :shell, inline: "yum -y install ansible"
    appnode1.vm.provision "file",
      source: "~/.gitconfig",
      destination: ".gitconfig"

    ## Disable selinux and reboot
    #unless FileTest.exist?("./untracked-files/first_boot_complete")
    #  appnode1.vm.provision :shell, inline: "yum -y update"
    #  appnode1.vm.provision :shell, inline: "sed -i s/^SELINUX=enforcing/SELINUX=permissive/ /etc/selinux/config"
    #  appnode1.vm.provision :reload
    #  require 'fileutils'
    #  FileUtils.touch("#{VAGRANTROOT}/untracked-files/first_boot_complete")
    #end

    # Install git and wget
    appnode1.vm.provision :shell, inline: "yum -y install git wget"
    # Load bashrc
    appnode1.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "${HOME}/.bashrc"
    appnode1.vm.provision "file", source: "#{VAGRANTROOT}/files/bashrc",
      destination: "/home/vagrant/.bashrc"

    # Load ssh keys
    appnode1.vm.provision "file", source: "#{VAGRANTROOT}/files/vagrant",
      destination: "/home/vagrant/.ssh/id_rsa"
    appnode1.vm.provision :shell, inline: "chmod 600 /home/vagrant/.ssh/id_rsa"
    appnode1.vm.provision :file, source: "#{VAGRANTROOT}/files/vagrant.pub",
      destination: "/home/vagrant/.ssh/id_rsa.pub"

    # Load /etc/hosts
    appnode1.vm.provision "shell", path: "./bin/hosts.sh", privileged: true

    ## Load ansible config to ~vagrant on the guest
    #appnode1.vm.provision "file",
    #  source: "#{VAGRANTROOT}/ansible/ansible.cfg",
    #  destination: "~vagrant/ansible.cfg"

    #appnode1.vm.provision "file",
    #  source: "#{VAGRANTROOT}/ansible/inventory",
    #  destination: "~vagrant/inventory"

    #appnode1.vm.provision "file",
    #  source: "#{VAGRANTROOT}/ansible/requirements.yml",
    #  destination: "~vagrant/requirements.yml"

    #appnode1.vm.provision "shell", inline: "[[ -d ~vagrant/playbooks ]] || \
    #  mkdir ~vagrant/playbooks/ && chown vagrant: ~vagrant/playbooks"

    #appnode1.vm.provision "file",
    #  source: "#{VAGRANTROOT}/ansible/playbooks/appnode1.yml",
    #  destination: "~vagrant/playbooks/appnode0.yml"

    # Run ansible provisioning
    appnode1.vm.provision :ansible do |ansible|
      ansible.verbose = "v"
      ansible.config_file = "#{VAGRANTROOT}/ansible/ansible.cfg"
      ansible.galaxy_roles_path  = "#{VAGRANTROOT}/ansible/roles"
      ansible.galaxy_role_file = "#{VAGRANTROOT}/ansible/requirements.yml"
      ansible.galaxy_command = "ansible-galaxy install --role-file=./ansible/requirements.yml --roles-path=./ansible/roles --force"
      ansible.playbook = "#{VAGRANTROOT}/ansible/playbooks/appnode0.yml"
    end
  end #!- appnode0

end
