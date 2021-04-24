#!/usr/bin/env bash

set -ex

export STEMBUILD_VERSION=`cat version/version`
export VM_NAME=`cat integration-vm-name/name`

export VCENTER_CA_CERT="$(openssl s_client -showcerts -connect ${VCENTER_BASE_URL}:443 2>/dev/null </dev/null | \
 sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')"

# We use an additional dns redirect that will cause TLS to fail
# So we fetch the hostname we're supposed to be using from the Cert
export VCENTER_BASE_URL=$(openssl x509 -noout -subject -in <(echo "$VCENTER_CA_CERT") | sed -e 's/^subject.*CN\s*=\s*\([a-zA-Z0-9\.\-]*\).*$/\1/')
export VCENTER_ADMIN_CREDENTIAL_URL=$(echo $VCENTER_ADMIN_CREDENTIAL_URL | sed "s/\(.*\)vcenter-nimbus.*/\1${VCENTER_BASE_URL}/")

ROOT_DIR=$(pwd)
OUTPUT_DIR=${ROOT_DIR}/output
export BOSH_PSMODULES_REPO=${ROOT_DIR}/bosh-psmodules-repo

export TARGET_VM_IP=`cat nimbus-ips/name`
echo "Using Existing VM IP: ${TARGET_VM_IP}"

echo ***Installing VMWare OVF Tools***
chmod +x ./ovftool/VMware-ovftool-4.2.0-5965791-lin.x86_64.bundle
./ovftool/VMware-ovftool-4.2.0-5965791-lin.x86_64.bundle --eulas-agreed --required

echo "***Creating GOPATH environment & structure ***"
export GOPATH=$PWD/gopath
export PATH=${GOPATH}/bin:$PATH

CF_INC_DIR=${GOPATH}/src/github.com/cloudfoundry-incubator
STEMBUILD_DIR=${ROOT_DIR}/stembuild
mkdir -p ${CF_INC_DIR}
cp -r ${STEMBUILD_DIR} ${CF_INC_DIR}

# install ginkgo
go get github.com/onsi/ginkgo/ginkgo

GO_STEMBUILD_DIR=${CF_INC_DIR}/stembuild
pushd ${GO_STEMBUILD_DIR}
  echo ***Test Stembuild Code***

  make integration
popd
