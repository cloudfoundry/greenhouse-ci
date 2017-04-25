#!/usr/bin/env powershell

cd "stemcell-builder"
bundle install
rake package:agent
rake package:psmodules
rake build:vsphere
