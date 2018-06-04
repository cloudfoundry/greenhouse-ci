$ErrorActionPreference = "Stop"
# Do not set error action preference let Pester handle it instead
$result = 0

$status = (Get-Service -Name "wuauserv").Status
$startupType = Get-Service "wuauserv" | Select-Object -ExpandProperty StartType | Out-String
"wuauserv status = * $status *"
"wuauserv startuptype = * $startupType *"

Import-Module ./stemcell-builder/src/github.com/pester/Pester/pester.psm1
foreach ($module in (Get-ChildItem "./stemcell-builder/bosh-psmodules/modules").Name) {
  Push-Location "./stemcell-builder/bosh-psmodules/modules/$module"
    Invoke-Pester -EnableExit
    if ($LASTEXITCODE -gt 0) {
      $result += $LASTEXITCODE
    }
  Pop-Location
}
echo "Failed Tests: $result"
exit $result
