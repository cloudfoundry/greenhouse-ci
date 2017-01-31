#!/usr/bin/env ruby

require 'net/ssh'

PACKER_VM_NAME = 'packer-vmware-iso'
REMOTE_HOST = ENV.fetch('REMOTE_HOST')
REMOTE_USERNAME = ENV.fetch('REMOTE_USERNAME')
REMOTE_PASSWORD = ENV.fetch('REMOTE_PASSWORD')
REMOTE_DATASTORE = ENV.fetch('REMOTE_DATASTORE')

def find_vmid (vms,vm_name)
  packer_present = false
  vms.each do |vm|
    vm_info = vm.split()
    if vm_info[1] == vm_name
      packer_present = true
      return vm_info[0]
    end
  end
  nil
end

Net::SSH.start(REMOTE_HOST, REMOTE_USERNAME, :password => REMOTE_PASSWORD) do |ssh|
  vms = ssh.exec!('vim-cmd vmsvc/getallvms').split("\n")[1..-1]

  puts vms

  if vms.nil? || vms.empty?
    puts "No running VMs, '#{PACKER_VM_NAME}' already cleaned up"
    next
  end
  vm_id = find_vmid(vms,PACKER_VM_NAME)
  if vm_id.nil? || vm_id.empty?
    puts "VM '#{PACKER_VM_NAME}' not running, already cleaned up"
    next
  end

  vm_id = vm_id.to_i
  if vm_id == 0
    abort("Cannot parse VM id of VM: '#{PACKER_VM_NAME}'")
  end

  ssh.exec!("vim-cmd vmsvc/power.off #{vm_id}")
  ssh.exec!("vim-cmd vmsvc/destroy #{vm_id}")

  # Check if vm data is still in datastore and remove if so
  vm_datastore_dir = "/vmfs/volumes/#{REMOTE_DATASTORE}/#{PACKER_VM_NAME}"
  puts ssh.exec!("if [ -d #{vm_datastore_dir} ]; then rm -r #{vm_datastore_dir}; fi")
end
