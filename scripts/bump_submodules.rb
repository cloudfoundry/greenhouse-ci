#!/usr/bin/env ruby

def sh(cmd)
  puts cmd
  system(cmd) || exit(1)
end

def submodules_changed?
  !system("git diff --exit-code")
end

sha = Dir.chdir("diego-release") do
  `git rev-list --max-count=1 HEAD`
end

Dir.chdir("diego-windows-release") do
  Dir.chdir("diego-release") do
    `git checkout #{sha.strip}`
  end

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
