#!/usr/bin/env ruby

require 'json'
require 'timeout'
require 'net/ssh'
require 'net/ssh/gateway'

def run_with_ssh(machine_ip: raise, ssh_key: raise, &block)
  options = {auth_methods: ["publickey"], use_agent: false, key_data: [ssh_key]}
  Net::SSH.start(machine_ip, 'ec2-user', options, &block)
end

class CellStatus
  def initialize(ssh: raise, target_url: raise)
    @ssh = ssh
    @target_url = target_url
  end

  def user_accounts
    @accounts ||= JSON.parse(run("#{target_url}/user_accounts"))
  end

  def directories
    @directories ||= JSON.parse(run("#{target_url}/directories"))
  end

  def memory_usage
    @memory_usage ||= JSON.parse(run("#{target_url}/memory_usage"))
  end

  def wait_for_deletion
    puts "waiting for LRPs to be deleted"
    Timeout.timeout(60) do
      run "#{target_url}/wait"
    end
    puts "LRPs have been deleted"
  end

  private

  def run cmd
    ssh.exec!("curl -s #{cmd}")
  end

  attr_reader :ssh, :target_url
end

run_with_ssh machine_ip: ENV["MACHINE_IP"], ssh_key: ENV["SSH_KEY"] do |ssh|
  cell_status = CellStatus.new(ssh: ssh, target_url: ENV["TARGET_URL"])

  cell_status.wait_for_deletion
  puts "MEMORY USAGE:\n #{cell_status.memory_usage}\n"

  if cell_status.user_accounts.any? || cell_status.directories.any? then
    puts "Found #{cell_status.user_accounts.size} accounts: #{cell_status.user_accounts}"
    puts "Found #{cell_status.directories.size} directories: #{cell_status.directories}"
    exit 1
  end

  puts "everything looks fine"
  exit 0
end
