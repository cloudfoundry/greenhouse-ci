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

def bump_diego_release sha
  Dir.chdir("diego-release") do
    system("git remote update")
    system("git checkout #{sha.strip}")
  end
end

def find_sha
  Dir.chdir("diego-release") do
    system("git rev-list --max-count=1 HEAD")
  end
end

sha = find_sha
trust_github
Dir.chdir("diego-windows-release") do
  bump_diego_release sha

  puts "----- Set git identity"
  sh 'git config user.email "cf-netgarden-eng@pivotal.io"'
  sh 'git config user.name "CI (Automated)"'

  puts "----- Update master branch on origin"
  if submodules_changed?
    sh 'git add -A'
    sh %{git diff --cached --submodule | ruby -e "puts 'Bump submodules'; puts; puts STDIN.read" | git commit --file -}
    puts "----- DEBUG: show the commit we just created"
    sh 'git --no-pager show HEAD'
  else
    puts "----- Nothing to commit"
  end
end
