#!/usr/bin/env ruby
require 'json'

dirs = %w(bosh-agent-zip bosh-agent-deps-zip windows-updates-list)
gits = %w(bosh-agent-sha)

bosh_windows_versions= JSON.load(File.read("bosh-windows/*.json"))
dirs.each do |dir|
  File.write("#{dir}/url", bosh_windows_versions[dir])
end

gits.each do |git|
  File.write("#{git}/sha",bosh_windows_versions[git])
end
