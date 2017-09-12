$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$ScriptPath = $MyInvocation.MyCommand.Path
$DirName = Split-Path $ScriptPath

mkdir "$DirName\bin"
mv "$DirName\stembuild\stembuild_windows_amd64.exe" "$DirName\bin\stembuild.exe"

$env:PATH="$DirName\bin;$env:PATH"

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
rake build:vsphere
if ($LASTEXITCODE -ne 0) {
  Write-Error "Could not build vsphere"
  Exit 1
}
