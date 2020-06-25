#!/usr/bin/env bash

set -ex

export VM_NAME_PREFIX="construct-linux-integration-ci-${OS_LINE}"

ROOT_DIR=$(pwd)
OUTPUT_DIR=${ROOT_DIR}/output

export VM_IP=`cat vcenter-ips/name`
export VM_NAME_SUFFIX=$(echo ${VM_IP} | cut -d . -f 4)
export VM_NAME=${VM_NAME_PREFIX}${VM_NAME_SUFFIX}
echo "Creating VM ${VM_NAME} with IP: ${VM_IP}"

govc vm.clone -u ${VCENTER_ADMIN_CREDENTIAL_URL} -vm ${BASE_VM_IPATH} -ds ${CLONE_DATASTORE} -pool ${CLONE_RESOURCE_POOL} -on=false $VM_NAME
govc vm.customize -u ${VCENTER_ADMIN_CREDENTIAL_URL} -vm.ipath /pizza-boxes-dc/vm/${VM_NAME} -ip ${VM_IP} ${VM_CUSTOMIZATION_NAME}
govc vm.power -on -u ${VCENTER_ADMIN_CREDENTIAL_URL} -vm.ipath /pizza-boxes-dc/vm/${VM_NAME}

echo Waiting for VM to be configured with expected IP address...
SECONDS=0
while [ "$VM_IP" != "$CURRENT_IP_ADDRESS" ]; do
	sleep 10
	CURRENT_IP_ADDRESS=$(govc vm.info -u "$VCENTER_ADMIN_CREDENTIAL_URL" -json /pizza-boxes-dc/vm/"$VM_NAME" | jq -r ".VirtualMachines[0].Guest.IpAddress")
	echo Current IP Address is "$CURRENT_IP_ADDRESS"
	if [ $SECONDS -gt 600 ] ; then
		exit 1
	fi
done

