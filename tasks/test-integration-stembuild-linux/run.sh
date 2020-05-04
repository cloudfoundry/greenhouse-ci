#!/usr/bin/env bash

set -ex

export STEMBUILD_VERSION=`cat version/version`
export VM_NAME_PREFIX="construct-windows-integration-ci-${OS_LINE}"

ROOT_DIR=$(pwd)
OUTPUT_DIR=${ROOT_DIR}/output

export USER_PROVIDED_IP=`cat vcenter-ips/name`
echo "Using Exiting VM IP: ${EXISTING_VM_IP}"

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
