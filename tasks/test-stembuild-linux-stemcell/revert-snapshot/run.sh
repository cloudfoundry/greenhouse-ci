#!/usr/bin/env bash
set -exu

govc snapshot.revert -u=${CREDENTIAL_URL} -s=true -dc=${DATACENTER} -vm=${VM_TO_REVERT} "${SNAPSHOT_NAME}"
