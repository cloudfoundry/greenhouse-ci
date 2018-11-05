$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

New-Item -Path "stemcell-builder" -ItemType "directory" -Name "build" -Force
cp stemcell-builder-release/agent.zip stemcell-builder/build/
cp stemcell-builder-release/bosh-psmodules.zip stemcell-builder/build/

pushd "stemcell-builder"

bundle install --without test
if ($LASTEXITCODE -ne 0) {
  Write-Error "Could not bundle install"
  Exit 1
}

rake build:vsphere_patchfile
if ($LASTEXITCODE -ne 0) {
  Write-Error "Could not build vsphere stemcell from patchfile"
  Exit 1
}

popd
