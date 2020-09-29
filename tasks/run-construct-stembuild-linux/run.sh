#!/usr/bin/env bash
set -ex

cat > ca.crt <<END_OF_CERT
$VCENTER_CA_CERT
END_OF_CERT
#export GOVC_TLS_CA_CERTS=ca.crt

pushd stembuild-untested-linux
  mv stembuild* stembuild
popd
mv stembuild-untested-linux/stembuild .

mv lgpo-binary/LGPO*.zip LGPO.zip

chmod 500 stembuild
./stembuild construct \
  -vcenter-ca-certs ca.crt \
  -vcenter-url ${VCENTER_BASE_URL} -vcenter-username ${VCENTER_USERNAME} -vcenter-password ${VCENTER_PASSWORD} \
  -vm-inventory-path ${VCENTER_VM_FOLDER}/${STEMBUILD_BASE_VM_NAME} \
  -vm-ip ${STEMBUILD_BASE_VM_IP} -vm-username ${STEMBUILD_BASE_VM_USERNAME} -vm-password ${STEMBUILD_BASE_VM_PASSWORD}

