#!/usr/bin/env bash
set -exu

export GOVC_INSECURE=1

echo "Snapshotting ${VM_TO_SNAPSHOT} to snapshot ${SNAPSHOT_NAME}"
govc snapshot.remove -dc=${DATACENTER} -vm=${VM_TO_SNAPSHOT} "${SNAPSHOT_NAME}"
govc snapshot.create -m=true -dc=${DATACENTER} -vm=${VM_TO_SNAPSHOT} "${SNAPSHOT_NAME}"
