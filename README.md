# vagrant-ansible-templates
Vagrant cofiguration for building an openshift cluster

## Table of Contents

1. [Overview] (#overview)
2. [Pre-Install] (#pre-install)
3. [Usage] (#usage)


#### Overview


#### Pre-Installaiton Setup

To run the vagrant installer you will need Virtualbox and vagrant vagrant running on your machine. If you're on a Mac the easiest way to install everything you'll need is with homebrew.  The following steps will install homebrew and vagrant

    $ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    $ brew cask install virtualbox
    $ brew cask install vagrant


#### Usage

    ansible -m ping -i ./inventory masters
    cd openshift-ansible
    ansible-playbook -i ../inventory playbooks/prerequisites.yml
    openshift-ansible]$ ansible-playbook -i ../inventory playbooks/deploy_cluster.yml

sudo chmod 777 /etc/ansible/facts.d/
