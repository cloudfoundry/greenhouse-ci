$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

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

cp stemcell-builder-release/agent.zip build/
cp stemcell-builder-release/bosh-psmodules.zip build/