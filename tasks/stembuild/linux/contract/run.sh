#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd `dirname "${BASH_SOURCE[0]}"`/../../../../.. && pwd)

echo "***Creating GOPATH environment & structure ***"
export GOPATH=$PWD/gopath
export PATH=${GOPATH}/bin:$PATH

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
