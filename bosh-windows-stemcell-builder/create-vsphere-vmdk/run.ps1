$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:VMDK_PATH="pivotal-base-image/en.2k12r2.serverdatacenter.rtm.fpp.patched.vhd"
$env:STARWIND_PATH="C:\Program Files (x86)\StarWind Software\StarWind V2V Image Converter"

$env:STARWIND_PATH\StarV2Vc.exe if="C:\Users\Administrator\Desk top\en.2k12r2.serverdatacenter.rtm.fpp.Patched-170509-050320.vhd" of="C:\Users\Administrator\Desktop\output.vmdk" ot=vmd k_s

cd "stemcell-builder"
bundle install

ruby ../ci/bosh-windows-stemcell-builder/create-vsphere-vmdk/run.rb
