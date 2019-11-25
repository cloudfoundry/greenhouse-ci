$ErrorActionPreference = "Stop"
# Do not set error action preference let Pester handle it instead
$result = 0

$status = (Get-Service -Name "wuauserv").Status
$startupType = Get-Service "wuauserv" | Select-Object -ExpandProperty StartType | Out-String
"wuauserv status = * $status *"
"wuauserv startuptype = * $startupType *"

Import-Module ./bosh-psmodules/src/github.com/pester/Pester/pester.psm1
foreach ($module in (Get-ChildItem "./bosh-psmodules/modules").Name) {
  Push-Location "./bosh-psmodules/modules/$module"
    $results=Invoke-Pester -PassThru
    if ($results.FailedCount -gt 0) {
      $result += $results.FailedCount
    }
  Pop-Location
}
echo "Failed Tests: $result"
exit $result
