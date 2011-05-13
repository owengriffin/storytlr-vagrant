Vagrant::Config.run do |config|
  config.vm.customize do |vm|
    vm.memory_size = 2048
  end
  config.vm.box = "lucid32"
  config.vm.box_url = "http://files.vagrantup.com/lucid32.box"
  config.vm.network "33.33.33.10"
  config.vm.forward_port "http", 80, 8080
  config.vm.forward_port "mysql", 3306, 3306
  config.vm.provision :shell, :path => "install.sh"
end
