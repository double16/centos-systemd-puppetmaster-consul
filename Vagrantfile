# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "bento/centos-7.2"

  config.vm.network "forwarded_port", guest: 8500, host: 18500

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "3000"
    vb.cpus = 2
  end

  config.vm.provider "vmware_fusion" do |v|
    v.vmx["memsize"] = "3000"
    v.vmx["numvcpus"] = "2"
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  config.vm.synced_folder ".", "/vagrant"

  config.vm.provision "shell", inline: <<-SHELL
	# Instructions based on http://mmclub.github.io/blog/2014/03/30/install-ruby-on-rails-on-centos/
	#  and https://gist.github.com/slayer/1513911

	# Disable SELinux (need to figure out how to make this work in docker)
	[ -f /etc/sysconfig/selinux ] && sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/sysconfig/selinux
	[ -f /etc/selinux/config ] && sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

	# Get the development tools
	yum install -y deltarpm
	yum -y update
	yum install -y docker-io
	systemctl enable docker.service
	usermod -a -G dockerroot vagrant
  SHELL

end
