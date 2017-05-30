$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:VMDK_PATH="pivotal-base-image/en.2k12r2.serverdatacenter.rtm.fpp.patched.vhd"

cd "stemcell-builder"
bundle install

ruby ../ci/bosh-windows-stemcell-builder/create-vsphere-vmdk/run.rb
