
Vagrant.configure("2") do |config|

	config.vm.define "solaris" do |solaris|
		solaris.vm.box = "MartijnDwars/solaris11_4"
		solaris.vm.hostname = "solaris"
		#solaris.vm.network "forwarded_port", guest: 22, host: 2201
		#solaris.vm.network "private_network", ip: "192.168.12.17"
		solaris.vm.synced_folder ".", "/vagrant"
#		solaris.vm.synced_folder "../ips", "/ips"
		solaris.vm.synced_folder "../../ips", "/ips"
#		solaris.vm.synced_folder "../Desktop/oraclecloud", "/oraclecloud"
		solaris.vm.synced_folder "../../Desktop/oraclecloud", "/oraclecloud"

		solaris.vm.provider "virtualbox" do |vb|
			vb.name = "solaris"
			vb.memory = "2048"
		end
		
	end

	config.vm.define "linux" do |linux|
		linux.vm.box = "ol77"
		linux.vm.hostname = "linux"
		linux.ssh.forward_x11 = true
		linux.vm.network "forwarded_port", guest: 22, host: 2203
		linux.vm.network "private_network", ip: "192.168.12.19"
		linux.vm.synced_folder ".", "/vagrant"
		
		linux.vm.provision "shell", path: "./scripts/setup_linux.sh"
		
		linux.vm.provider "virtualbox" do |vb|
			vb.name = "linux"
			vb.memory = "2048"
		end
		
	end

end
