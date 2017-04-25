#!/usr/bin/env powershell

cd stemcell-builder
bundle install
rake package:psmodules
rake build:vsphere_add_updates
