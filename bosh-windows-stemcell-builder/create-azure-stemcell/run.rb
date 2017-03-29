#!/usr/bin/env ruby

require 'fileutils'
require 'open3'

def exec_command(cmd)
  STDOUT.sync = true
  puts "Running: #{cmd}"
  Open3.popen2(cmd) do |stdin, out, wait_thr|
    out.each_line do |line|
      puts line
    end
    exit_status = wait_thr.value
    if exit_status != 0
      raise "error running command: #{cmd}"
    end
  end
end

FileUtils.mkdir_p(File.join('stemcell-builder','build'))
FileUtils.cp_r('windows-stemcell-dependencies', File.join('stemcell-builder','build','windows-stemcell-dependencies'))
FileUtils.cp_r('version', File.join('stemcell-builder','build','version'))

Dir.chdir 'stemcell-builder' do
  exec_command('bundle install')
  exec_command('rake package:agent')
  exec_command('rake package:psmodules')
  exec_command('rake build:azure')
end
