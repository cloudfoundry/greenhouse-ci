#!/usr/bin/env bash

set -ex

export CLONE_NAME_PREFIX="construct-${JOB_OS_NAME}-integration-ci-${OS_LINE}"

ROOT_DIR=$(pwd)
OUTPUT_DIR=${ROOT_DIR}/output

export VM_IP=`cat vsphere-bloodmyst-ips/name`
export CLONE_NAME_SUFFIX=$(echo ${VM_IP} | cut -d . -f 4)
export CLONE_NAME=${CLONE_NAME_PREFIX}${CLONE_NAME_SUFFIX}
mkdir integration-vm-name
echo ${CLONE_NAME} > integration-vm-name/name
echo "Creating VM ${CLONE_NAME} with IP: ${VM_IP}"

govc vm.clone -u ${VCENTER_ADMIN_CREDENTIAL_URL} -vm ${BASE_VM_IPATH} -ds ${CLONE_DATASTORE} -pool ${CLONE_RESOURCE_POOL} -folder "$CLONE_FOLDER" -on=false "$CLONE_NAME"
govc vm.customize -u ${VCENTER_ADMIN_CREDENTIAL_URL} -vm.ipath "$CLONE_FOLDER"/"$CLONE_NAME" -ip ${VM_IP} ${VM_CUSTOMIZATION_NAME}
govc vm.power -on -u ${VCENTER_ADMIN_CREDENTIAL_URL} -vm.ipath "$CLONE_FOLDER"/"$CLONE_NAME"

echo Waiting for VM to be configured with expected IP address...
SECONDS=0
while [ "$VM_IP" != "$CURRENT_IP_ADDRESS" ]; do
	sleep 10
	CURRENT_IP_ADDRESS=$(govc vm.info -u "$VCENTER_ADMIN_CREDENTIAL_URL" -json "$CLONE_FOLDER"/"$CLONE_NAME" | jq -r ".VirtualMachines[0].Guest.IpAddress")
	echo Current IP Address is "$CURRENT_IP_ADDRESS"
	if [ $SECONDS -gt 600 ] ; then
		exit 1
	fi
done

