#!/usr/bin/env bash

set -exu

#govc snapshot.revert -u=${CREDENTIAL_URL} -s=true -dc=${DATACENTER} -vm=${VM_TO_REVERT} "${SNAPSHOT_NAME}"


function powershellCmd() {
	local vm_ipath="${1}"
	local vm_username="${2}"
	local vm_password="${3}"
	local script="${4}"

	if ! pid=$(govc guest.start -ipath=${vm_ipath} -l=${vm_username}:${vm_password} \
		'C:\\Windows\\System32\\WindowsPowerShell\\V1.0\\powershell.exe -NoProfile -Command "'+${script}+'"'); then
		writeErr "could not run powershell command on VM at ${vm_ipath}"
		return 1
	fi

	if ! processInfo=$(govc guest.ps -ipath=${vm_ipath} -l=${vm_username}:${vm_password} -p=${pid} -X=true -x -json); then
		writeErr "could not get powershell process info on VM at ${vm_ipath}"
		return 1
	fi

	if ! exitCode=$(echo "${processInfo}" | jq '.info.ProcessInfo[0].ExitCode'); then
		writeErr "process info not be parsed for powershell command on VM at ${vm_ipath}"
		return 1
	fi

	echo "${exitCode}"
	return 0
}

function restartVM() {
	local vm_ipath="${1}"

	if ! govc vm.power -vm.ipath=${vm_ipath} -r=true -wait=true; then
		writeErr "Could not restart VM at ${vm_ipath}"
		return 1
	fi

	return 0
}
function writeErr() {
	local msg="${1}"
	echo "[ERROR]: ${msg}"
}

echo "--------------------------------------------------------"
echo "Running windows update"
echo "--------------------------------------------------------"
echo -ne "|"

# TODO: Change to 'while' not fully updated

updates_needed=true

while (${updates_needed}); do
	if ! exitCode=$(powershellCmd "${VM_TO_REVERT}" "${VCENTER_USERNAME}" "${VCENTER_PASSWORD}" "Get-WUInstall -AcceptAll -IgnoreReboot"); then
		writeErr "could not run windows update"
		exit 1
	fi

	if [[ ${exitCode} == "1" ]]; then
		writeErr "windows update process exited with error"
		exit 1
	fi

	if ! restartVM "${VM_TO_REVERT}"; then
		writeErr "could not restart VM"
		exit 1
	fi

	if ! updateExitCode=$(powershellCmd "${VM_TO_REVERT}" "${VCENTER_USERNAME}" "${VCENTER_PASSWORD}" "If ((Get-WindowsUpdate).Count -eq 0) {exit 0} Else {exit 1}"); then
	  writeErr "could not get windows update"
	  exit 1
	fi

	if [[ ${updateExitCode} == "0" ]] ; then
	  echo "installed all necessary windows updates"
	  updates_needed=false
	fi

	echo -ne "."
done



# TODO: Add create snapshot of updated VM

# while not up to date
### install windows updates
### restart (block on coming back up)

# print a list of updates that are installed (Get-Hotfix type deal)

# create new snapshot with update VM