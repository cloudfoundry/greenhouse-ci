$ErrorActionPreference = "Stop";
trap { Exit 1 }

Import-Module ./ci/common-scripts/setup-windows-container.psm1
Set-TmpDir

Write-Host ***Test Stembuild Code***
Set-Location stembuild
make units
if ($lastexitcode -ne 0)
{
  throw "unit tests failed"
}
