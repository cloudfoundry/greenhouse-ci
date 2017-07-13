$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

cd "stemcell-builder"
bundle install
if ($LASTEXITCODE -ne 0) {
  Write-Error "Could not bundle install"
  Exit 1
}
rake package:agent
if ($LASTEXITCODE -ne 0) {
  Write-Error "Could not package agent"
  Exit 1
}
rake package:psmodules
if ($LASTEXITCODE -ne 0) {
  Write-Error "Could not package psmodules"
  Exit 1
}

ruby -e "STDOUT.sync = true; STDERR.sync = true" -e "load ARGV.shift" ../ci/bosh-windows-stemcell-builder/create-vsphere-vmdk/run.rb
