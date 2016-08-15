#!/usr/bin/env ruby
require 'json'

dirs = %w(bosh-agent-zip bosh-agent-deps-zip windows-updates-list)
gits = %w(bosh-agent-sha)

files = Dir.glob("bosh-windows/bosh-windows-*.json")
if files.empty?
  abort "No bosh-windows lock found"
end
bosh_windows_versions= JSON.load(File.read(files[0]))
dirs.each do |dir|
  File.write("#{dir}/url", bosh_windows_versions[dir])
end

gits.each do |git|
  File.write("#{git}/sha",bosh_windows_versions[git])
end
