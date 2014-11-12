# -*- coding: utf-8 -*-
# -*- mode: ruby -*-
# vi: set ft=ruby :

# NOTE: You cannot pass any parameters to vagrant. The only way is to use
# environment variables, eg:
#    MY_VAR='my value' vagrant up
#    And use ENV['MY_VAR'] in recipe.

VAGRANTFILE_API_VERSION = "2"

HOSTNAME = 'elife.vbox.local'

# VM options

#VM_BOX = "ubuntu/trusty64"
VM_BOX = "ubuntu/precise64"
VM_GUI = false

VM_IP = "192.168.33.44"
VM_RAM = "4096"
VM_VIDEO_RAM = "12" # TODO: only applicable when running a gui
VM_CPUS = 4

# AWS options

AWS_AMI = "ami-98aa1cf0"  # ubuntu/images/ebs-ssd/ubuntu-trusty-14.04-amd64-server-20140927
AWS_REGION = "us-east-1"
AWS_ACCESS_KEY = ENV['AWS_KEY_ID']
AWS_SECRET_KEY = ENV['AWS_SECRET_KEY']
AWS_KEYPAIR_NAME = ENV['AWS_KEYPAIR_NAME']
AWS_PRIVATE_KEY_PATH = ENV['AWS_KEY_PATH']
AWS_INSTANCE_TYPE = "m1.small"

# environment options

VPN_ENABLED = false
FILE_CHECKS = true

NFS_SHARES = false

#
# 
#

if not VPN_ENABLED
  puts "[info] VPN disabled"
end

public_dir = "./public"

file_checks = [
  public_dir + "/jnl-elife.sql",
  public_dir + "/settings.php"
]

if VPN_ENABLED
  file_checks.concat [
    public_dir + "/client.crt",
    public_dir + "/client.crt",
    public_dir + "/client.key",
    public_dir + "/ca.crt",
    public_dir + "/ta.key"
  ]
end

warnings = 0
file_checks.each do |fname|
  if !File.exist?(fname)
    puts "[warn] file '#{fname}' is missing"
    warnings += 1
  end
end

if warnings > 0 and FILE_CHECKS
  print "\nWarnings have been issued: continue? [yes/No] "
  STDOUT.flush
  ans = STDIN.gets.chomp.strip.downcase
  abort unless (ans === "yes")
  puts ""
end

#
# 
#

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # If true, then any SSH connections made will enable agent forwarding.
  config.ssh.forward_agent = true # default: false

  if NFS_SHARES
    config.vm.synced_folder public_dir, "/opt/public", id: "vagrant-root", nfs: true
    config.vm.synced_folder "../drupal-site-jnl-elife", "/shared/elife_module", id: "vagrant-elife", nfs: true
  else
    config.vm.synced_folder public_dir, "/opt/public", id: "vagrant-root", :owner => "www-data", :group => "www-data", :mount_options => [ "dmode=775", "fmode=664" ]
    config.vm.synced_folder "../drupal-site-jnl-elife", "/shared/elife_module", id: "vagrant-elife", :owner => "www-data", :group => "www-data", :mount_options => [ "dmode=775", "fmode=664" ]
  end

  config.vm.box = VM_BOX

  config.vm.host_name = HOSTNAME
  config.vm.network :forwarded_port, host: 4567, guest: 80

  config.vm.provider :aws do |aws, override|
    override.vm.box = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    aws.access_key_id = AWS_ACCESS_KEY
    aws.secret_access_key = AWS_SECRET_KEY
    aws.keypair_name = AWS_KEYPAIR_NAME
    override.ssh.private_key_path = AWS_PRIVATE_KEY_PATH

    aws.instance_type = AWS_INSTANCE_TYPE
    aws.security_groups = ["default-vpn"]

    aws.ami = AWS_AMI
    aws.region = AWS_REGION

    override.ssh.username = "ubuntu"
    aws.tags = {
      'Name' => 'Elife Vagrant VPN',
    }
  end

  config.vm.provider :virtualbox do |vb|
    vb.gui = VM_GUI
    vb.customize ["modifyvm", :id, "--cpus", VM_CPUS]
    vb.customize ["modifyvm", :id, "--memory", VM_RAM]
    vb.customize ["modifyvm", :id, "--vram", VM_VIDEO_RAM]
    config.vm.network :private_network, ip: VM_IP
  end

  # ensures the SSH_AUTH_SOCK envvar is retained when salt sudos to root
  # this allows the root user to talk to private git repos
  config.vm.provision "shell", inline: "echo 'Defaults>root env_keep+=SSH_AUTH_SOCK' > /etc/sudoers.d/00-ssh-auth-sock-root" # TODO: is this still useful?
  config.vm.synced_folder "salt/root/", "/srv/salt/"
  #config.vm.synced_folder "salt/pillar/", "/srv/pillar/" # TODO: not being used

  config.vm.provision :salt do |salt|
    salt.verbose = true
    salt.install_type = "git"
    salt.install_args = "v2014.7"
    salt.minion_config = "salt/minion"
    salt.run_highstate = true
    salt.pillar({
        "vpn" => {
            "enabled" => VPN_ENABLED
        }
    })
  end 

end
