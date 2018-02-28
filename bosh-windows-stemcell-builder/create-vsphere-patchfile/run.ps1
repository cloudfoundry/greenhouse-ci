$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

pushd "stemcell-builder"

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

rake build:vsphere_patchfile
if ($LASTEXITCODE -ne 0) {
  Write-Error "Could not build vsphere stemcell from patchfile"
  Exit 1
}

popd
