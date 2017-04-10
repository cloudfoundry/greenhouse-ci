#!/usr/bin/env ruby
require 'json'

dirs = %w(stemcell-builder
          stemcell-builder/src/github.com/cloudfoundry/bosh-agent
          stemcell-builder/src/github.com/cloudfoundry-incubator/bosh-windows-acceptance-tests)

stemcell = Dir.glob("final-stemcell/*.tgz")[0]
final_version = stemcell.match(/\d+\.\d+/)[0]

shas = dirs.inject({}) do |acc, dir|
  acc[dir.split('/').last] = `cd #{dir}; git rev-parse HEAD`.chomp
  acc
end

File.write(
  File.join('stemcell-info', "stemcell-#{final_version}.json"),
  JSON.dump(shas)
)
