#!/usr/bin/env ruby

require 'json'
require 'timeout'
require_relative './ssh.rb'

class CellStatus
  def initialize(ssh: raise)
    @ssh = ssh
  end

  def user_accounts
    # see https://msdn.microsoft.com/en-us/library/aa392263.aspx for more info about the LIKE operator
    @accounts ||= run "powershell /C Get-WmiObject -Class Win32_UserAccount -Filter 'name LIKE ''c[_]%''' | ForEach {$_.Name}"
  end

  def directories
    @directories ||= run "powershell /C ls C:\\Containerizer | ForEach {$_.Name}"
  end

  def memory_usage
    keys = ["totalvisiblememorysize", "freephysicalmemory", "totalvirtualmemorysize", "freevirtualmemory"]
    foreach_keys = keys.map { |k| "$_.#{k}" }.join(",")
    values = run "powershell /C \"Get-WmiObject win32_OperatingSystem | ForEach {#{foreach_keys}}\""
    Hash[keys.zip(values)]
  end

  def wait_for_deletion
    puts "waiting for LRPs to be deleted"
    Timeout.timeout(60) do
      loop do
        response = ssh.exec! %{powershell /C (new-object net.webclient).DownloadString('http://localhost:1800/state')}
        parsed = JSON.parse(response)
        if parsed["LRPs"].empty?
          break
        end
        sleep(1)
      end
    end
    puts "LRPs have been deleted"
  end

  private

  def run cmd
    resp = ssh.exec!(cmd) || ""
    resp.split("\r\n")
  end

  attr_reader :ssh
end

run_with_ssh machine_ip: ENV["MACHINE_IP"], jump_machine_ip: ENV["JUMP_MACHINE_IP"], jump_machine_ssh_key: ENV["JUMP_MACHINE_SSH_KEY"] do |ssh|
  cell_status = CellStatus.new(ssh: ssh)

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
