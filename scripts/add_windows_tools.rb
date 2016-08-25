#!/usr/bin/env ruby

require 'yaml'

yml = YAML.load_file(ARGV[0])

yml['releases'].push('name' => 'windows-tools-release',
                     'version' => 'latest')

yml['jobs'].each do |j|
  j['templates'].push('name' => 'longrunning-server',
                      'release' => 'windows-tools-release')
end

File.open(ARGV[1], 'w') { |file| YAML.dump(yml, file) }
