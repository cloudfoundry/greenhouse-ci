#!/usr/bin/env ruby

require 'fileutils'

require_relative '../../../stemcell-builder/lib/exec_command'

ENV["STEMCELL_PATH"] = File.absolute_path(ENV["STEMCELL_PATH"])

Dir.chdir 'stemcell-builder' do
  exec_command('bundle install')
  exec_command('rake package:bwats')
  exec_command("rake run:bwats[#{ENV["IAAS"]}]")
end
