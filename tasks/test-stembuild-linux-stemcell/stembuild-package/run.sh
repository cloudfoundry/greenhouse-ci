#!/usr/bin/env bash

set -ex

pushd stembuild-untested-linux
  mv stembuild* stembuild
popd
mv stembuild-untested-linux/stembuild .

chmod 500 stembuild

version="$(cat build-number/number)"
IFS='.' read -r -a array <<< "$version"
patch_version="${array[2]}.${array[3]}"

./stembuild package \
  -vcenter-url ${VCENTER_BASE_URL} -vcenter-username ${VCENTER_USERNAME} -vcenter-password ${VCENTER_PASSWORD} -vm-inventory-path ${VCENTER_VM_FOLDER}/${STEMBUILD_BASE_VM_NAME} -patch-version ${patch_version}

mv *.tgz stembuild-built-stemcell

