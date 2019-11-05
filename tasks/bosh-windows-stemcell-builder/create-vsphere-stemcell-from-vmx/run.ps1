$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

New-Item -ItemType Directory -Force -Path $env:VMX_CACHE_DIR

Write-Host "Copying stembuild (${PWD}\stembuild\stembuild-windows-x86_64-*.exe) to: ${PWD}\bin\stembuild.exe"
mkdir "${PWD}\bin"
mv "${PWD}\stembuild\stembuild-windows-x86_64-*.exe" "${PWD}\bin\stembuild.exe"

$env:PATH="${PWD}\bin;$env:PATH"

$env:BOSH_AGENT_DIR="$(pwd)/$env:BOSH_AGENT_DIR"
pushd "${env:BOSH_AGENT_DIR}"
  $CURRENT_VERSION=$(Get-Content .resource/version)
  mv bosh-agent*.exe bosh-agent.exe
popd

pushd "stemcell-builder"
bundle install --without test
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Could not bundle install"
    Exit 1
  }
  pushd src/github.com/cloudfoundry/bosh-agent
    git checkout "v$CURRENT_VERSION"
  popd

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
popd
mv stemcell-builder/hotfixes.log hotfix-log/
