#!/usr/bin/env ruby

require_relative './ssh.rb'

class CellStatus
  def initialize(ssh: raise)
    @ssh = ssh
  end

  def user_accounts
    ssh.exec!("powershell /C Get-WmiObject -Class Win32_UserAccount -Filter 'name LIKE ''c_%''' | ForEach {$_.Name}").split("\r\n")
  end

  def directories
    ssh.exec!("powershell /C ls C:\\Containerizer | ForEach {$_.Name}").split("\r\n")
  end

  def containerizer_disk_usage
    ssh.exec!("powershell /C Get-ChildItem C:\\Containerizer -recurse | Measure-Object -property length -sum")
  end

  def memory_usage
    ssh.exec!("powershell /C powershell /C Get-WmiObject win32_OperatingSystem | ForEach {$_.totalvisiblememorysize,$_.freephysicalmemory,$_.totalvirtualmemorysize,$_.freevirtualmemory}")
  end

  private

  attr_reader :ssh
end

run_with_ssh machine_ip: ENV["MACHINE_IP"], jump_machine_ip: ENV["JUMP_MACHINE_IP"], jump_machine_ssh_key: ENV["JUMP_MACHINE_SSH_KEY"] do |ssh|
  cell_status = CellStatus.new(ssh: ssh)

  if cell_status.user_accounts.any? || cell_status.directories.any? then
    puts "Found #{cell_status.user_accounts.size} accounts"
    puts "Found #{cell_status.directories.size} directories"
    exit 1
  end

  puts "everything looks fine"
  exit 0
end
