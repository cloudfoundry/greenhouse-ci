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

time sudo arping -f ${VM_IP}
## write the IP address and inventory path of the created VM to somewhere in /output
