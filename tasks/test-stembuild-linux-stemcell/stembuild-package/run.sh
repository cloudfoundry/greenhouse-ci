#!/usr/bin/env bash

set -ex

pushd stembuild-untested-linux
  mv stembuild* stembuild
popd
mv stembuild-untested-linux/stembuild .

chmod 500 stembuild

./stembuild package \
  -vcenter-url ${VCENTER_BASE_URL} -vcenter-username ${VCENTER_USERNAME} -vcenter-password ${VCENTER_PASSWORD} -vm-inventory-path ${VCENTER_VM_FOLDER}/${STEMBUILD_BASE_VM_NAME}

mv *.tgz stembuild-built-stemcell

