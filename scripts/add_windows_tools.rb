#!/usr/bin/env ruby

require 'yaml'

yml = YAML.load_file(ARGV[0])

yml['releases'].append('name' => 'windows-tools-release',
                       'version' => 'latest')

yml['jobs'].each do |j|
  j['templates'].push('name' => 'longrunning-server',
                      'release' => 'windows-tools-release')
end

YAML.dump(yml, $stdout)
