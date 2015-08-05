require 'net/ssh'
require 'net/ssh/gateway'

def run_with_ssh(machine_ip:raise, jump_machine_ip:raise, jump_machine_ssh_key:raise, &block)
  options = {auth_methods: ["publickey"], use_agent: false, key_data: [jump_machine_ssh_key]}
  if jump_machine_ip
    gateway = Net::SSH::Gateway.new(jump_machine_ip, 'ec2-user', options)
    gateway.ssh(machine_ip, "ci", options, &block)
  else
    Net::SSH.start(machine_ip, "ci", options, &block)
  end
end
