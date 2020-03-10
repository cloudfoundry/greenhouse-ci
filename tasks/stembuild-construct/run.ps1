$ErrorActionPreference = "Stop";
trap { Exit 1 }

Import-Module ./ci/tasks/common/setup-windows-container.psm1
Set-TmpDir

pushd stembuild-untested-windows
    Move-Item stembuild* stembuild.exe
popd

Move-Item stembuild-untested-windows/stembuild.exe .

Move-Item lgpo/LGPO*.zip LGPO.zip

ICACLS stembuild.exe /grant:r "users:(RX)" /C

Write-Host ".\stembuild.exe construct -vcenter-url $env:VCENTER_BASE_URL -vcenter-username $env:VCENTER_USERNAME -vcenter-password <redacted> -vm-inventory-path $env:VCENTER_VM_FOLDER/$env:STEMBUILD_BASE_VM_NAME -vm-ip $env:STEMBUILD_BASE_VM_IP -vm-username $env:STEMBUILD_BASE_VM_USERNAME -vm-password <redacted>"
.\stembuild.exe construct -vcenter-url $env:VCENTER_BASE_URL -vcenter-username $env:VCENTER_USERNAME -vcenter-password $env:VCENTER_PASSWORD -vm-inventory-path $env:VCENTER_VM_FOLDER/$env:STEMBUILD_BASE_VM_NAME -vm-ip $env:STEMBUILD_BASE_VM_IP -vm-username $env:STEMBUILD_BASE_VM_USERNAME -vm-password $env:STEMBUILD_BASE_VM_PASSWORD