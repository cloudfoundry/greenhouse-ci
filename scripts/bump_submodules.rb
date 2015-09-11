#!/usr/bin/env ruby

def sh(cmd)
  puts cmd
  system(cmd) || exit(1)
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
  sh 'git add -A'
  sh %{git diff --cached --submodule | ruby -e "puts 'Bump submodules'; puts; puts STDIN.read" | git commit --file -}

  puts "----- DEBUG: show the commit we just created"
  sh 'git --no-pager show HEAD'
end
