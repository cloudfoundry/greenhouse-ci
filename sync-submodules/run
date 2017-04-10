#!/usr/bin/env ruby

def sh(cmd)
  puts cmd
  system(cmd) || exit(1)
end

def submodules_changed?
  !system("git diff --exit-code")
end

def trust_github
  system("mkdir ~/.ssh")
  system("ssh-keyscan github.com >> ~/.ssh/known_hosts")
end

def find_sha(release, submodule)
  Dir.chdir(release) do
    `git rev-parse :#{submodule}`.chomp
  end
end

def bump_downstream(submodule, sha)
  Dir.chdir("downstream-release") do
    Dir.chdir(submodule) do
      system("git remote update")
      system("git checkout #{sha.strip}")
    end
  end
end

SUBMODULES = ENV.fetch("SUBMODULES").split(",")
SUBMODULES.each do |submodule|
  downstream_sha = find_sha("downstream-release", submodule)
  upstream_sha = find_sha("upstream-release", submodule)
  if upstream_sha !=  downstream_sha
    bump_downstream(submodule, upstream_sha)
  end
end
trust_github
Dir.chdir("downstream-release") do
  puts "----- Set git identity"
  sh 'git config user.email "cf-netgarden-eng@pivotal.io"'
  sh 'git config user.name "CI (Automated)"'

  puts "----- Updating submodules"
  if submodules_changed?
    sh 'git add -A'
    sh %{git diff --cached --submodule | ruby -e "puts 'Bump submodules'; puts; puts STDIN.read" | git commit --file -}
    puts "----- DEBUG: show the commit we just created"
    sh 'git --no-pager show HEAD'
  else
    puts "----- Nothing to commit"
  end
end

sh 'git clone ./downstream-release ./bumped-downstream-release'
