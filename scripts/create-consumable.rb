#!/usr/bin/env ruby
require 'json'

urls = dirs.map do |dir|
  [dir, File.read("#{dir}/url").chomp]
end
urls = Hash[urls]

version = File.read('bosh-windows-shipit-version/version').chomp
filename = "bosh-windows-client-consumable/bosh-windows-#{version}.json"

File.write(filename, JSON.dump(urls))
