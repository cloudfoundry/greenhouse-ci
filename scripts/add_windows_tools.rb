#!/usr/bin/env ruby

require 'yaml'

yml = YAML.load_file(ARGV[0])

yml['releases'].push('name' => 'windows-tools-release',
                     'version' => 'latest')

yml['networks'].push('name' => 'longrunning-cell', 'type' => 'vip')

yml['jobs'].each do |j|
  j['templates'].push('name' => 'longrunning-server',
                      'release' => 'windows-tools-release')
end
yml['jobs'].first['networks'].push('name' => 'longrunning-cell',
                                   'static_ips' => ['54.87.171.179'])

File.open(ARGV[1], 'w') { |file| YAML.dump(yml, file) }
