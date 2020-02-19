$ErrorActionPreference = "Stop";
trap { Exit 1 }

Import-Module ./ci/tasks/common/setup-windows-container.psm1
Set-TmpDir

pushd stembuild-untested-windows
    Move-Item stembuild* stembuild.exe
popd

Move-Item stembuild-untested-windows/stembuild.exe .

ICACLS stembuild.exe /grant:r "users:(RX)" /C

.\stembuild.exe package -vcenter-url $env:VCENTER_BASE_URL -vcenter-username $env:VCENTER_USERNAME -vcenter-password $env:VCENTER_PASSWORD -vm-inventory-path $env:VCENTER_VM_FOLDER/$env:STEMBUILD_BASE_VM_NAME

Move-Item *.tgz stembuild-built-stemcell