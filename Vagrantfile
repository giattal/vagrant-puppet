# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "icalvete/ror-ubuntu-18.04-64-puppet"
  config.vm.box_version = "0.0.1"
#   config.vm.box = "puppetlabs/ubuntu-16.04-64-puppet"

  config.vm.define "web-a" do |web|
    web.vm.hostname = "web-a"
    web.vm.network :private_network, ip: "192.168.10.111"

    web.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
  end

  config.vm.define "web-b" do |web|
    web.vm.hostname = "web-b"
    web.vm.network :private_network, ip: "192.168.10.112"
    
    web.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
  end

  config.vm.define "balancer" do |hap|
    hap.vm.hostname = "balancer"
    hap.vm.network :private_network, ip: "192.168.10.10"
    hap.vm.network "forwarded_port", guest: 8888, host: 8888
    hap.vm.network "forwarded_port", guest: 9090, host: 9090

    hap.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 2
    end
  end

  # Enable shell provisioning to bootstrap puppet
  config.vm.provision :shell, :path => "bootstrap.sh"
  # Enable provisioning with Puppet stand alone.
  config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file  = "site.pp"
        puppet.module_path = "puppet/modules"
        puppet.options = "--verbose --debug"
  end 
end
