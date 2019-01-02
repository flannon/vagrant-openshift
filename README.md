# vagrant-ansible-templates
Templates for building vagrant boxes for 


## Table of Contents

1. [Overview] (#overview)
2. [Pre-Install] (#pre-install)
3. [Usage] (#usage)


#### Overview

Provides templates for building the follwoing vagrant boxes

    - Centos 7 (templates)
    - awx

#### Pre-Installaiton Setup

To run the vagrant installer you will need Virtualbox and vagrant vagrant running on your machine. If you're on a Mac the easiest way to install everything you'll need is with homebrew.  The following steps will install homebrew and vagrant

    $ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    $ brew cask install virtualbox
    $ brew cask install vagrant


#### Usage

Clone vagrant templates, checkout the branch you want to build and
then vagrant up. i.e. To build vagrant-awx do the following,

    $ git clone https://gitlab.com/flannon/vagrant-ansible-templates \
      vagrant-awx
    $ cd vagrant-awx
    $ git checkout awx
    $ vagrant up


To connect to your vagrant box you can,

    $ vagrant ssh

Or, to connect directly from a local shell to the bagrant box,

    $ ssh vagrant@172.25.250.254 -i ~/.vagrant.d/insecure_private_key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o PasswordAuthentication=no -o IdentitiesOnly=yes

