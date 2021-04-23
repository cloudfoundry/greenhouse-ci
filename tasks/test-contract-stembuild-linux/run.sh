#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(pwd)

echo "***Creating GOPATH environment & structure ***"
export GOPATH=$PWD/gopath
export PATH=${GOPATH}/bin:$PATH

export VCENTER_CA_CERT="$(openssl s_client -showcerts -connect ${VCENTER_BASE_URL}:443 2>/dev/null </dev/null | \
 sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p')"

# We use an additional dns redirect that will cause TLS to fail
# So we fetch the hostname we're supposed to be using from the Cert
export VCENTER_BASE_URL=$(openssl x509 -noout -subject -in <(echo "$VCENTER_CA_CERT") | sed -e 's/^subject.*CN=\([a-zA-Z0-9\.\-]*\).*$/\1/')

CF_INC_DIR=${GOPATH}/src/github.com/cloudfoundry-incubator
STEMBUILD_DIR=${ROOT_DIR}/stembuild
mkdir -p ${CF_INC_DIR}
cp -r ${STEMBUILD_DIR} ${CF_INC_DIR}

# install ginkgo
go get github.com/onsi/ginkgo/ginkgo
go get -u github.com/vmware/govmomi/vcsim

GO_STEMBUILD_DIR=${CF_INC_DIR}/stembuild
pushd ${GO_STEMBUILD_DIR}
  echo ***Test Stembuild Code***

  make contract
popd
