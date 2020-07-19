#!/bin/bash

if which puppet > /dev/null ; then
        echo "Puppet is already installed"
        exit 0
fi
echo "Installing Puppet repo for Ubuntu"

wget https://apt.puppetlabs.com/puppet6-release-$(lsb_release -cs).deb
dpkg -i puppet6-release-$(lsb_release -cs).deb
apt-get -qq update
echo "Installing puppet"
apt-get install -y puppet
echo "Puppet installed!"


