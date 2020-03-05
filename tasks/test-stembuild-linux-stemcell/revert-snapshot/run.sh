#!/usr/bin/env bash
set -eu

#check if there is a network device attached, if not, add, maybe check power state too
echo "Retrieving device info to ensure vm has networking"
set +e
govc device.info  -u ${CREDENTIAL_URL} -vm.ipath=${VM_TO_REVERT} 'ethernet-*'
ethernetPresent=$?
set -e
if [[ ${ethernetPresent} -ne 0 ]] ; then
    set -e
    echo "No network device present, adding network device to VM"
    govc vm.network.add  -u ${CREDENTIAL_URL} -vm.ipath=${VM_TO_REVERT} -net="calgary" -net.adapter="e1000e"
fi
set -e

echo "Reverting ${VM_TO_REVERT} to snapshot ${SNAPSHOT_NAME}"
govc snapshot.revert -u=${CREDENTIAL_URL} -s=true -dc=${DATACENTER} -vm=${VM_TO_REVERT} "${SNAPSHOT_NAME}"
govc vm.power -u=${CREDENTIAL_URL} -dc=${DATACENTER} -on=true ${VM_TO_REVERT}
