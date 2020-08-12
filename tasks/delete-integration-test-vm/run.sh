#!/usr/bin/env bash

set -ux # Do not set 'e' as govc will fail if the vm has already been cleaned up

export VM_NAME=$(cat integration-vm-name/name)
export VM_IPATH="${CLONE_FOLDER}/${VM_NAME}"

govc vm.destroy -u "${VCENTER_ADMIN_CREDENTIAL_URL}" -vm.ipath "${VM_IPATH}"

exit 0
