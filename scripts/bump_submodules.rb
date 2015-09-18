#!/usr/bin/env ruby

def sh(cmd)
  puts cmd
  system(cmd) || exit(1)
end

def submodules_changed?
  !system("git diff --exit-code")
end

modules = Dir.chdir("diego-release") do
  `git submodule status --recursive`
end

Dir.chdir("diego-windows-msi") do
  modules.split(/\n/).each do |line|
    a = line.split(/\s+/)
    sha = a[1]
    dir = a[2]
    puts dir

    next if dir =~ /gorilla\/websocket/

    if Dir.exists?(dir)
      puts "\t#{sha}"
      Dir.chdir(dir) do
        `git checkout #{sha}`
      end
    end
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
