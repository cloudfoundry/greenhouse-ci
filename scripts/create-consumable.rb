#!/usr/bin/env ruby
require 'json'

dirs = %w(bosh-agent-zip bosh-agent-deps-zip windows-updates-list)

urls = dirs.map do |dir|
  [dir, File.read("#{dir}/url").chomp]
end
urls = Hash[urls]
urls['bosh-agent'] = `cd bosh-agent; git rev-parse HEAD`.chomp

version = File.read('bosh-windows-shipit-version/version').chomp
filename = "bosh-windows-client-consumable/bosh-windows-#{version}.json"

File.write(filename, JSON.dump(urls))
