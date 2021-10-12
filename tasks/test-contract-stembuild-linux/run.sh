#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(pwd)
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

source ${SCRIPT_DIR}/../../common-scripts/update_nimbus_urls_and_cert.sh

echo "***Creating GOPATH environment & structure ***"
export GOPATH=$PWD/gopath
export PATH=${GOPATH}/bin:$PATH

CF_INC_DIR=${GOPATH}/src/github.com/cloudfoundry-incubator
STEMBUILD_DIR=${ROOT_DIR}/stembuild
mkdir -p ${CF_INC_DIR}
cp -r ${STEMBUILD_DIR} ${CF_INC_DIR}

# install vcsim for vCenter manager and client contract integration tests
go get -u github.com/vmware/govmomi/vcsim

GO_STEMBUILD_DIR=${CF_INC_DIR}/stembuild
pushd ${GO_STEMBUILD_DIR}
  echo ***Test Stembuild Code***

  make contract
popd
