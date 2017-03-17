# Do not set error action preference let Pester handle it instead

Import-Module ./stemcell-builder/src/github.com/pester/Pester/pester.psm1
cd ./stemcell-builder/bosh-psmodules/modules/BOSH.Agent/
Invoke-Pester -EnableExit
