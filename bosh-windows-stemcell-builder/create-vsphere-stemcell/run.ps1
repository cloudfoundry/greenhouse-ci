$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

cd "stemcell-builder"
$(bundle install) -or $(Write-Error 'Failed to install')
$(rake package:agent) -or $(Write-Error 'Failed to install')
$(rake package:psmodules) -or $(Write-Error 'Failed to package psmodules')
$(rake build:vsphere) -or $(Write-Error 'Failed to create vsphere stemcell')
