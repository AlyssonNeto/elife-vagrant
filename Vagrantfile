# -*- coding: utf-8 -*-
# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Variation configuration: starts with ELIFE_ to indicate these items
# are for this setup.
ELIFE_CONFIGURE_OPENVPN = true         # set to false to disable OpenVPN configuration

# use :chef to switch back to original provisioning
PROVISIONER = :salt

# Putting this code here, like this, means it is run whenever the Vagrant command
# is run. At present I don't know of a way to make it more specific to, for example
# 'up' or 'provision' commands.

public_dir = "public"
warnings = 0

# These tests are needed if you are configuring OpenVPN
if ELIFE_CONFIGURE_OPENVPN

  if !File.exist?(public_dir + "/client.crt")
    puts "WARNING: Client VPN certificate client.crt is missing."
    warnings = warnings + 1
  end
  if !File.exist?(public_dir + "/client.key")
    puts "WARNING: Client VPN key client.key is missing."
    warnings = warnings + 1
  end
  if !File.exist?(public_dir + "/ca.crt")
    puts "WARNING: Client Authority certificate ca.crt is missing."
    warnings = warnings + 1
  end
  if !File.exist?(public_dir + "/ta.key")
    puts "WARNING: Client TLS key ta.key is missing."
    warnings = warnings + 1
  end

end

# These tests are needed to run up the Drupal site.

if !File.exist?(public_dir + "/jnl-elife.sql")
  puts "WARNING: Website database dump jnl-elife.sql.gz is missing."
  warnings = warnings + 1
end
if !File.exist?(public_dir + "/settings.php")
  puts "WARNING: Website settings file settings.php is missing."
  warnings = warnings + 1
end

# If there is a problem, let the user have a chance to fix it
if warnings > 0
  print "\nWarnings have been issued: abort this command? [Yes/No] "
  STDOUT.flush
  ans = STDIN.gets.chomp.strip
  abort unless (ans === "no" || ans === "No")
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "./public", "/opt/public", id: "vagrant-root", :owner => "www-data", :group => "www-data", :mount_options => [ "dmode=775", "fmode=664" ]

  # this expects the drupal-site-jnl-elife git repository checked out in the same parent folder
  config.vm.synced_folder "../drupal-site-jnl-elife", "/shared/elife_module", id: "vagrant-elife", :owner => "www-data", :group => "www-data", :mount_options => [ "dmode=775", "fmode=664" ]

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"

  config.vm.host_name = 'elife.vbox.local'
  config.vm.network :forwarded_port, host: 4567, guest: 80

  config.vm.provider :aws do |aws, override|

    override.vm.box = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    # Install latest version of Chef
    override.omnibus.chef_version = :latest

    aws.access_key_id = ENV['AWS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_KEY']
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    override.ssh.private_key_path = ENV['AWS_KEY_PATH']

    # You cannot pass any parameters to vagrant. The only way is to use
    # environment variables, eg:
    #    MY_VAR='my value' vagrant up
    #    And use ENV['MY_VAR'] in recipe.

    aws.instance_type = "m1.large"
    aws.security_groups = [ "default-vpn" ]

    aws.ami = "ami-de0d9eb7" # TODO: what sort of box is this?
    aws.region = "us-east-1"

    override.ssh.username = "ubuntu"
    aws.tags = {
      'Name' => 'Elife Vagrant VPN',
     }

  end # of aws provider

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider :virtualbox do |vb|

    # Boot in headless mode
    vb.gui = false

    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.customize ["modifyvm", :id, "--vram", "12"]

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    config.vm.network :private_network, ip: "192.168.33.44"

  end # of vbox provider

  # ensures the SSH_AUTH_SOCK envvar is retained when salt sudos to root
  # this allows the root user to talk to private git repos
  config.vm.provision "shell", inline: "echo 'Defaults>root env_keep+=SSH_AUTH_SOCK' > /etc/sudoers.d/00-ssh-auth-sock-root" # TODO: is this still useful?

  config.vm.synced_folder "salt/root/", "/srv/salt/"
  config.vm.synced_folder "salt/pillar/", "/srv/pillar/"

  config.vm.provision :salt do |salt|
    salt.verbose = true
    salt.install_type = "git"
    salt.minion_config = "salt/minion"
    salt.run_highstate = true
  end # of salt provision

end
