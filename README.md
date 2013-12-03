# About

This repo contains the provisioning information for setting up a dev environment for building a local
copy of [drupal-site-jnl-elife](https://github.com/elifesciences/drupal-site-jnl-elife).

It is being built on top of the [drupal - vagrant project](https://drupal.org/project/vagrant), with the
configuration moved to v2 of the vagrant API, and using librarian and chef for managing cookbooks.

# Preqrequisites:

Git on local host
Git user created and with access to the elifesciences repository
Vagrant 1.3.4 or 1.3.5 installed
VirtualBox v4.2 or 4.3 installed (needed for shared folders)

  - Use of VirtualBox 4.3 requires Vagrant 1.3.5

Tunnelblick installed on the host (Required for local VM access to VPN servers, not used by AWS)

AWS access requires two vagrant plugins to be installed:

 - vagrant-aws
 - vagrant-omnibus

Install these using:

	vagrant plugin install vagrant-aws
	vagrant plugin install vagrant-omnibus

# Setup

To setup your system to work with Vagrant and Chef please follow the guide provided at
[elife-template-env](https://github.com/elifesciences/elife-template-env).

The first time that you run vagrant it will attempt to detect whether you have the required base box on
your machine. If you haven't then it will download this for you. If you wish to run this step manually
then you can do so with the following command:

	./jnl boxes

Set up Tunnelblick to connect to Highwire using the key provided, and then connect.

# Quickstart

On the master branch, the script 'jnl' can be used to populate a directory:

	mkdir work-feature ; cd work-feature
	git clone git@github.com:elifesciences/elife-vagrant.git
	( cd elife-vagrant ; ./jnl preinstall )

This will checkout the drupal-highwire and drupal-site-jnl-elife repos in the work-feature folder, that is
beside, not within, elife-vagrant. To do this by hand:

	mkdir work-feature ; cd work-feature
	git clone git@github.com:elifesciences/elife-vagrant.git
	git clone git@github.com:elifesciences/drupal-highwire.git
	git clone git@github.com:elifesciences/drupal-site-jnl-elife.git

Now, Locate a copy of the journal database dump and save as a gzipped compressed file
to .../elife-vagrant/public/jnl-elife.sql.gz, and locate a copy of the settings.php file (with drupal
passwords and database setup) and save in .../elife-vagrant/public/settings.php

	librarian-chef install && vagrant up

	## not necessary, but to check the server out, do:
	vagrant ssh

The site is set up to accept connections using http://elife.vbox.local:8080// so on the host configure
/etc/hosts to include/extend a line such as:

	127.0.0.1    localhost  elife.vbox.local

# Vagrant GUI

The Vagrantfile-gui includes the changes that enables the VirtualBox to come up with a console window,
rather than being headless. This obviously only works with VirtualBox so this file is also missing the
AWS configuration.

You may find the folllowing installation helpful, which installs the Xserver, a basic window manager, a
couple of browsers and the text editor geany:

    sudo apt-get install xorg xfce4 chromium-browser firefox geany

Netbeans is helpful for debugging locally, and the simplest way to get it running is to go to the Sun website
and get the netbeans installer from here:

	https://netbeans.org/downloads/index.html

Get an installer that includes Oracle Java 7 SE, which is at time of writing 89MB. Once started, go to
the Plugins UI and enable the PHP plugin, which will be downloaded and installed. After a netbeans
restart you should be able to make a "new project" "PHP from existing sources".


# Amazon AWS

To run an instance on Amazon rather than on a local Virtualbox you will need to set up an Amazon EC2 account
and gain access to various keys. Once you have done this, save them and construct a script file such as the
following:

	# Joe Bloggs AWS
	export AWS_KEY_ID="A..................A"
	export AWS_SECRET_KEY="7......................................q"
	export AWS_KEYPAIR_NAME="joebloggs"
	export AWS_KEY_PATH="~/.ssh/joebloggs.pem"

You can add these entries to your .bashrc file or make them separate and 'source' them from a specific
file when you need to use vagrant-aws:

    . ~/.aws_keys

The Vagrantfile in elife-vagrant must me changed slightly to support AWS:

 - The line starting "config.vm.box = pre64" must be commented out and the one below it mentioning
   "dummy" must be uncommented.
 - The line starting config.omnibus.chef_version must be uncommented

Optionally, the mapping 'Name' => 'Elife Vagrant VPN' can be changed if you want to name your instance.

Having saved those changes, you can start up the VM for the first time using:

    vagrant up --provider=aws

Subsequently you don't need to add --provider; it is recorded in the ".vagrant" folder metadata. In
particular, you never need --provider=aws with a "provision".

## OpenVPN

If running with AWS you will need an OpenVPN session. You need 4 files, which you should obtain
from Highwire and are specific to you:

 - client.key
 - client.crt
 - ca.crt
 - ta.key

These files are used to identify one VPN session: you cannot connect from more than one machine (local
or remote, VM or otherwise) at a time. The only exception is that a tunnelblick session run on a Mac
can be used by things running on that Mac, whether in a VM or not.

The keys must be in the elife-vagrant/public folder when you provision the VM, so at first when you do
a vagrant up and later if you do a vagrant provision. They do not need to be there otherwise, as the
keys are copied onto VM-local disk (in /etc/openvpn).

Configuration of the VM is controlled by drupal-site-jnl-elife-cookbook:recipes/openvpnc.rb


# Restarting

Some changes can be made using 'vagrant provision' though it is possible for some sorts of change to
be overlooked this way:

	vagrant provision

To remake from scratch, and so ensure all is ok, do:

	cd elife-vagrant      # in this directory
	rm -rf cookbooks  tmp  Cheffile.lock
	librarian-chef install && vagrant up


# What it does

Cookbooks are installed using librarian. Check the `Cheffile` to see which cookbooks we donwnlad as
community cookbooks, and which ones we have made private instances of. (Creating a private instance of
a cookbook is an anti-pattern, however for our immediate purposes, this is OK).

Librarian also installs the git repo for the elife specific drupal modules and themes.

This git repo includes the `roles` provided by the drupal vagrant proejct. These have been modified to
not install varnish or memcached. This was done out of convinience.

This git repo contains a placeholder `public` directory. This is the directory that is used to serve
our drupal site out of.


## elife journal drupal code

- [drupal-site-jnl-elife][eldcode] - the source code for the elife drupal site
- [drupal-site-jnl-elife-env][eldprovision] - Vagrant and Cheffile for building the vm
- [drupal-site-jnl-elife-cookbook][eldcook] - Chef cookbook called by Cheffile for building the dev environment

[eldcode]: https://github.com/elifesciences/drupal-site-jnl-elife
[eldprovision]: https://github.com/elifesciences/drupal-site-jnl-elife-env
[eldcook]: https://github.com/elifesciences/drupal-site-jnl-elife-cookbook

## Issues with the Drupal Install

## TODO

- apc has been turned off, as getting it to install via chef was beyond me.

- contribute back fixes to the main vagrant-drupal project, and stop holiding a private version of these cookbooks.
