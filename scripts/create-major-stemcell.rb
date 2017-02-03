#!/usr/bin/env ruby
require 'json'

dirs = %w(bosh-agent stemcell-builder bwats)

stemcell = Dir.glob("bosh-windows-stemcell/*.tgz")[0]
final_version = stemcell.match(/\d+\.\d+/)[0]

shas = dirs.inject({}) do |acc, dir|
  acc[dir] = `cd #{dir}; git rev-parse HEAD`.chomp
  acc
end

File.write(
  File.join('stemcell-info', "stemcell-#{final_version}.json"),
  JSON.dump(shas)
)
