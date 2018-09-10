#!/usr/bin/env bash

set -ex

VERSION=`cat stempatch-version/version`
ROOT_DIR=$(cd `dirname "${BASH_SOURCE[0]}"`/../../.. && pwd)
OUTPUT_DIR=${ROOT_DIR}/output

echo ***Installing VMWare OVF Tools***
chmod +x ./ovftool/VMware-ovftool-4.2.0-5965791-lin.x86_64.bundle
./ovftool/VMware-ovftool-4.2.0-5965791-lin.x86_64.bundle --eulas-agreed --required

echo ***Generating librsync sources***
LIBRSYNC_DIR=${ROOT_DIR}/librsync
LIBRSYNC_BUILD_DIR=${LIBRSYNC_DIR}/build
LIBRSYNC_INSTALL_DIR=${LIBRSYNC_DIR}/install
LIBRSYNC_BLAKE2_DIR=${LIBRSYNC_DIR}/src/blake2

mkdir -p ${LIBRSYNC_BUILD_DIR}
mkdir -p ${LIBRSYNC_INSTALL_DIR}

pushd ${LIBRSYNC_BUILD_DIR}
  cmake -DCMAKE_INSTALL_PREFIX=${LIBRSYNC_INSTALL_DIR} -DCMAKE_BUILD_TYPE=release -G "Unix Makefiles" ..
  make
  make test
popd

echo ***Copying librsync sources into stempatch***
STEMPATCH_DIR=${ROOT_DIR}/stempatch
STEMPATCH_RDIFF_DIR=${STEMPATCH_DIR}/rdiff

pushd ${STEMPATCH_RDIFF_DIR}
  # We add the true at the end because a non-recursive copy will fail if it cannot copy a subdirectory
  # when copying with wildstar. However, the files in the root directory does get copied.
  cp ${LIBRSYNC_DIR}/src/* . || true
  cp ${LIBRSYNC_BUILD_DIR}/src/* .
  cp ${LIBRSYNC_BLAKE2_DIR}/* .
  rm rdiff.c
popd

echo "***Creating GOPATH environment & structure ***"
export GOPATH=$PWD/gopath
export PATH=${GOPATH}/bin:$PATH

CF_DIR=${GOPATH}/src/github.com/pivotal-cf
mkdir -p ${CF_DIR}
cp -r ${STEMPATCH_DIR} ${CF_DIR}

# install ginkgo
go get github.com/onsi/ginkgo/ginkgo
go install github.com/onsi/ginkgo/ginkgo

GO_STEMPATCH_DIR=${CF_DIR}/stempatch
pushd ${GO_STEMPATCH_DIR}
  echo ***Test Stempatch Code***
  make units
  make integration

  echo ***Building Stempatch***
  go build
popd

echo ***Copying stempatch to output directory***
cp ${GO_STEMPATCH_DIR}/stempatch ${OUTPUT_DIR}/stempatch-linux-x86_64-${VERSION}


