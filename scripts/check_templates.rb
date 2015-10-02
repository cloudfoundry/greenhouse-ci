#!/usr/bin/env ruby

def diego_windows_release_tag
  `cat diego-windows-github-release/tag`
end

def checkout_diego_windows_release(version)
  Dir.chdir("diego-windows-release") do
    `git checkout #{version}`
  end
end

def diego_submodule_sha
  Dir.chdir("diego-windows-release") do
    `git rev-parse :diego-release`.chomp
  end
end

def git_log_of_rep_template_for(diego_sha)
  Dir.chdir("diego-release") do
    system("git log --exit-code #{diego_sha}.. -- jobs/rep/templates/rep_ctl.erb")
  end
end

checkout_diego_windows_release(diego_windows_release_tag)
git_log_of_rep_template_for(diego_submodule_sha)
exit $?.exitstatus
