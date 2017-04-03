# Do not set error action preference let Pester handle it instead

Import-Module ./stemcell-builder/src/github.com/pester/Pester/pester.psm1
$modules = "BOSH.Utils","BOSH.Agent","BOSH.Sysprep", "BOSH.CFCell"
foreach ($module in $modules) {
  Push-Location "./stemcell-builder/bosh-psmodules/modules/$module"
    Invoke-Pester -EnableExit
  Pop-Location
}
