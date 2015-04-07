Vagrant.configure(2) do |config|
    config.vm.guest = :windows
    config.vm.communicator = "winrm"
    config.winrm.username = "IEUser"
    config.winrm.password = "Passw0rd!"

    config.vm.network :forwarded_port, guest: 5985, host: 59851,
        id: "winrm", auto_correct:true
    config.vm.network :forwarded_port, guest: 3389, host: 33891,
        id: "rdp", auto_correct:true

    config.vm.boot_timeout = 300
	config.vm.box_url = "http://artel-solutions.com/vagrant-win7-ie11-xebia.box"
    config.vm.box = "win7-ie11-xebia"

    config.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = "1024"
        vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    end
end
