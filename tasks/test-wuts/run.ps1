$ErrorActionPreference = "Stop"

$status = (Get-Service -Name "wuauserv").Status
$startupType = Get-Service "wuauserv" | Select-Object -ExpandProperty StartType | Out-String
"wuauserv status = * $status *"
"wuauserv startuptype = * $startupType *"

cd .\windows-utilities-tests\assets\wuts-release\jobs\check_windowsdefender\templates\m

$pesterResults = Invoke-Pester -PassThru
if ($pesterResults.FailedCount -gt 0) {
    Exit 1
}

Exit 0

#foreach ($module in (Get-ChildItem "./stemcell-builder/bosh-psmodules/modules").Name) {
#    Push-Location "./stemcell-builder/bosh-psmodules/modules/$module"
#    $results=Invoke-Pester -PassThru
#    if ($results.FailedCount -gt 0) {
#        $result += $results.FailedCount
#    }
#    Pop-Location
#}
#echo "Failed Tests: $result"
#exit $result
