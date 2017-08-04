$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

cd "stemcell-builder"
bundle install
if ($LASTEXITCODE -ne 0) {
  Write-Error "Could not bundle install"
  Exit 1
}

rake build:vsphere_from_diff
if ($LASTEXITCODE -ne 0) {
  Write-Error "Could not build vsphere stemcell from diff"
  Exit 1
}
