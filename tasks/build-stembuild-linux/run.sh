#!/usr/bin/env bash

set -ex

VERSION=`cat stembuild-version/version`
ROOT_DIR=$(cd `dirname "${BASH_SOURCE[0]}"`/../../.. && pwd)
OUTPUT_DIR=${ROOT_DIR}/output

echo ***Installing VMWare OVF Tools***
chmod +x ./ovftool/VMware-ovftool-4.2.0-5965791-lin.x86_64.bundle
./ovftool/VMware-ovftool-4.2.0-5965791-lin.x86_64.bundle --eulas-agreed --required

echo "***Creating GOPATH environment & structure ***"
export GOPATH=$PWD/gopath
export PATH=${GOPATH}/bin:$PATH

CF_EXP_DIR=${GOPATH}/src/github.com/pivotal-cf-experimental
STEMBUILD_DIR=${ROOT_DIR}/stembuild
mkdir -p ${CF_EXP_DIR}
cp -r ${STEMBUILD_DIR} ${CF_EXP_DIR}

# install ginkgo
go get github.com/onsi/ginkgo/ginkgo
go install github.com/onsi/ginkgo/ginkgo

GO_STEMBUILD_DIR=${CF_EXP_DIR}/stembuild
pushd ${GO_STEMBUILD_DIR}
  echo ***Test Stembuild Code***
  make units
  make integration

  echo ***Building Stembuild***
  go build
popd

echo ***Copying stembuild to output directory***
cp ${GO_STEMBUILD_DIR}/stembuild ${OUTPUT_DIR}/stembuild-linux-x86_64-${VERSION}


