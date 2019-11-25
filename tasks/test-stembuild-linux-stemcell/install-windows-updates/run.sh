#!/bin/bash

set -e

export GOVC_URL="${CREDENTIAL_URL}"

vm_ipath=${STEMBUILD_CONSTRUCT_TARGET_VM}
vm_username=${VM_USERNAME}
vm_password=${VM_PASSWORD}

powershell_exe="\\Windows\\System32\\WindowsPowerShell\\V1.0\\powershell.exe"

# get wu-install /wu-update set up to work on the vm...

function wait_for_vm_to_come_up() {
  result=-1
  set +e
  while [[ result -ne 0 ]]; do
    # try to connect
    govc guest.start -vm.ipath=${vm_ipath} -l=${vm_username}:${vm_password} $powershell_exe Get-ChildItem \\ 2> /dev/null
    result=$?
    sleep 1
  done
  set -e
}

updates_remaining=-1
while [[ updates_remaining -ne 0 ]]; do
  install_update_pid=$(
    govc guest.start -vm.ipath=${vm_ipath} -l=${vm_username}:${vm_password} $powershell_exe Install-WindowsUpdate -AcceptAll -AutoReboot
  )
  echo "install-WU pid is $install_update_pid"


  # ignore unreachable agent if the vm just went down for reboot
  # -X blocks until the guest process exits
  set +e
  govc guest.ps -vm.ipath="${vm_ipath}" -l="${vm_username}:${vm_password}" -p=${install_update_pid} -X
  set -e
  echo "Install-WU done"

  # wait for VM to go down and poll for connectivity
  echo "Waiting for VM to come back after reboot, if necessary..."
  sleep 60
  wait_for_vm_to_come_up

  echo "VM reachable"

  returnWindowsUpdateCount="exit ((Get-WindowsUpdate).Count)"
  get_update_count_pid=$(govc guest.start -vm.ipath=${vm_ipath} -l=${vm_username}:${vm_password} $powershell_exe ${returnWindowsUpdateCount})
	updates_remaining=$(govc guest.ps -vm.ipath="${vm_ipath}" -l="${vm_username}:${vm_password}" -p=${get_update_count_pid} -X -json | jq '.ProcessInfo[0].ExitCode')
	echo "Updates remaining: $updates_remaining"
done
