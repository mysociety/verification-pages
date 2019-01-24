# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'debian/stretch64'

  config.vm.network 'forwarded_port', guest: 3035, host: 3035 # webpack websocket for live reload
  config.vm.network 'forwarded_port', guest: 5000, host: 5000 # rails app
  config.vm.network 'forwarded_port', guest: 8000, host: 8000 # id-mapping-store

  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder '.', '/home/vagrant/verification-pages'

  config.vm.provider 'virtualbox' do |vb|
    vb.customize ['modifyvm', :id, '--memory', 1024]
    vb.customize ['modifyvm', :id, '--cpus', 2]
  end

  config.vm.provision :shell, privileged: false, path: 'script/provision.sh'

  config.ssh.forward_agent = true

  config.vm.post_up_message = <<~TXT
    Log into the Vagrant box with \`vagrant ssh\` and run:
      foreman start
  TXT
end
