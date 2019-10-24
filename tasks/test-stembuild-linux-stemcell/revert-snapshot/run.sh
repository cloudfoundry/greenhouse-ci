#!/usr/bin/env bash
set -exu

govc snapshot.revert -u=${CREDENTIAL_URL} -s=true -dc=${DATACENTER} -vm=${VM_TO_REVERT} "${SNAPSHOT_NAME}"
govc vm.power -u=${CREDENTIAL_URL} -dc=${DATACENTER} -on=true ${VM_TO_REVERT}