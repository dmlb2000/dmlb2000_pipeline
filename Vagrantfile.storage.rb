Vagrant.configure("2") do |config|
  config.vm.provider :libvirt do |libvirt|
    libvirt.storage :file, :size => '20G'
    libvirt.storage :file, :size => '20G'
  end
end
