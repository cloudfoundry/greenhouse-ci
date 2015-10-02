#!/usr/bin/env ruby

# get the things
# jobs/rep/templates/rep_ctl.erb changed?
# blow up!
# profit.

def checkout_last_release
  Dir.chdir("diego-windows-release") do
    `git checkout $(cat ../diego-windows-github-release/tag)`
  end
end

def diego_windows_release_diego_sha
  Dir.chdir("diego-windows-release") do
    `git rev-parse :diego-release`.chomp
  end
end

def compare_versions(diego_sha)
  Dir.chdir("diego-release") do
    `git log ..#{diego_sha} jobs/rep/templates/rep_ctl.erb`.chomp
  end
end

checkout_last_release
compare_versions(diego_windows_release_diego_sha)
