$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

cd "stemcell-builder"
bundle install
rake package:agent
rake package:psmodules
rake build:vsphere
