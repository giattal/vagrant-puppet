# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.define "web1" do |web|
    web.vm.box = "bento/ubuntu-16.04"
    web.vm.hostname = "web1"
    web.vm.network :private_network, ip: "192.168.10.11"

    web.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
  end

  config.vm.define "web2" do |web|
    web.vm.box = "bento/ubuntu-16.04"
    web.vm.hostname = "web2"
    web.vm.network :private_network, ip: "192.168.10.12"
    
    web.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
  end

  config.vm.define "balancer" do |hap|
    hap.vm.box = "puppetlabs/ubuntu-16.04-64-puppet"
    hap.vm.hostname = "balancer"
    hap.vm.network :private_network, ip: "192.168.10.10"
    hap.vm.network "forwarded_port", guest: 80, host: 80
    hap.vm.network "forwarded_port", guest: 8888, host: 8888

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