# About

This repo contains provisioning information for configuring a dev environment 
of [drupal-site-jnl-elife](https://github.com/elifesciences/drupal-site-jnl-elife).

# TL;DR

* $ ./jnl preinstall
* copy your settings.py to public/
* copy journal dump as .sql to salt/root/elife/
* # echo '127.0.0.1  elife.vbox.local' >> /etc/hosts
* vagrant up
* firefox elife.vbox.local

# Preqrequisites:

* Git installed on host, Github account with your public key attached
* drupal-webroot and drupal-highwire checkouts
* ssh-agent
* Vagrant >= v1.3.4
* VirtualBox >= v4.2 (needed for shared folders)
* database dump
* OpenVPN & VPN credentials

## drupal-webroot and drupal-highwire

Two repositories, `drupal-webroot` and `drupal-highwire` should exist in the 
parent directory. These can be cloned with the command:

    $ ./jnl preinstall

## ssh-agent

_note:_ OSX has had this [integrated by default](http://en.wikipedia.org/wiki/Ssh-agent#Status_on_Mac_OS_X)
since Leopard, apparently, but problems are still being encountered.

In order for the provisioner to connect to private repositories, it uses the 
program `ssh-agent`. If `ssh-agent` is absent or is missing your private key, it 
will fail with a "permission denied" type error.

On Linux, install `ssh-agent` with your distribution's package manager.

Add this to the end of your `~/.bashrc` or to the system's `/etc/profile` file:

    eval $(ssh-agent)
    ssh-add
    
If you use a key other than the default to connect, you can add that key 
specifically with:

    ssh-add /path/to/other/private-key

More details [here](https://wiki.archlinux.org/index.php/SSH_keys#ssh-agent).

## database dump

A dump of the eLife's drupal database must exist to be loaded. The raw dump is
quite large (~1.3GB at time of writing) however a smaller version is available.

Directions using an unpacked + sanitized version of the database can be 
[found here](https://github.com/elifesciences/drupal-site-jnl-elife-db).

## OpenVPN

OpenVPN is currently _NOT_ configured with salt provisioning.

If running with AWS you will need an OpenVPN session. You need 4 files, which 
you should obtain from Highwire and are specific to you:

 - client.key
 - client.crt
 - ca.crt
 - ta.key

These files are used to identify one VPN session: you cannot connect from more 
than one machine (local or remote, VM or otherwise) at a time. The only 
exception is that a tunnelblick session run on a Mac can be used by things 
running on that Mac, whether in a VM or not.

The keys must be in the elife-vagrant/public folder when you provision the VM, 
so at first when you do a vagrant up and later if you do a vagrant provision. 
They do not need to be there otherwise, as the keys are copied onto VM-local 
disk (in /etc/openvpn).

Configuration of the VM is controlled by drupal-site-jnl-elife-cookbook:recipes/openvpnc.rb

## settings.php

...

## AWS access

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

Optionally, the mapping 'Name' => 'Elife Vagrant VPN' can be changed in the Vagrantfile if you want to name your instance.

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


# Troubleshooting

## AWS Keys not provided

The error:

	There are errors in the configuration of this machine. Please fix
	the following errors and try again:

	AWS Provider:
	* An access key ID must be specified via "access_key_id"
	* A secret access key is required via "secret_access_key"

means you haven't setup your AWS keys (or your shell isn't passing them into the script). This
could be because you are using a separate file (such as ".aws_keys") and you haven't 'sourced'
the file into the current shell.

## Librarian-Chef Not Run

The error:

	[default] The cookbook path '/work/work-aws-openvpn2/elife-vagrant/cookbooks' doesn't exist. Ignoring...

means you haven't run:

	librarian-chef install

(or it failed to run correctly).



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
