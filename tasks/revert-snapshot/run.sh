#!/usr/bin/env bash
set -eu

cat > ca.crt <<END_OF_CERT
$VCENTER_CA_CERT
END_OF_CERT
export GOVC_TLS_CA_CERTS=ca.crt

echo "Retrieving device info to ensure vm has networking"
if ! govc device.info  -u ${CREDENTIAL_URL} -vm.ipath=${VM_TO_REVERT} 'ethernet-*' ; then
    echo "No network device present, adding network device to VM"
    govc vm.network.add  -u ${CREDENTIAL_URL} -vm.ipath=${VM_TO_REVERT} -net="calgary" -net.adapter="e1000e"
    govc device.info  -u ${CREDENTIAL_URL} -vm.ipath=${VM_TO_REVERT} 'ethernet-*'
fi

echo "Reverting ${VM_TO_REVERT} to snapshot ${SNAPSHOT_NAME}"
govc snapshot.revert -u=${CREDENTIAL_URL} -s=true -dc=${DATACENTER} -vm=${VM_TO_REVERT} "${SNAPSHOT_NAME}"
govc vm.power -u=${CREDENTIAL_URL} -dc=${DATACENTER} -on=true ${VM_TO_REVERT}
