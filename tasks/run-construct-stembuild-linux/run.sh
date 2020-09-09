#!/usr/bin/env bash
set -ex

pushd stembuild-untested-linux
  mv stembuild* stembuild
popd
mv stembuild-untested-linux/stembuild .

mv lgpo-binary/LGPO*.zip LGPO.zip

chmod 500 stembuild
./stembuild construct \
  -vcenter-url ${VCENTER_BASE_URL} -vcenter-username ${VCENTER_USERNAME} -vcenter-password ${VCENTER_PASSWORD} \
  -vm-inventory-path ${VCENTER_VM_FOLDER}/${STEMBUILD_BASE_VM_NAME} \
  -vm-ip ${STEMBUILD_BASE_VM_IP} -vm-username ${STEMBUILD_BASE_VM_USERNAME} -vm-password ${STEMBUILD_BASE_VM_PASSWORD}

