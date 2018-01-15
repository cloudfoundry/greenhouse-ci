#!/usr/bin/env bash

set -ex

VERSION=`cat stembuild-version/version`
ROOT_DIR=$(cd `dirname "${BASH_SOURCE[0]}"`/../.. && pwd)
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

echo ***Copying librsync sources into stembuild***
STEMBUILD_DIR=${ROOT_DIR}/stembuild
STEMBUILD_RDIFF_DIR=${STEMBUILD_DIR}/rdiff

pushd ${STEMBUILD_RDIFF_DIR}
  cp ${LIBRSYNC_DIR}/src/* .
  cp ${LIBRSYNC_BUILD_DIR}/src/* .
  cp ${LIBRSYNC_BLAKE2_DIR}/* .
  rm rdiff.c
popd

echo "***Creating GOPATH environment & structure ***"
export GOPATH=$PWD/gopath
export PATH=${GOPATH}/bin:$PATH

CF_EXP_DIR=${GOPATH}/src/github.com/pivotal-cf-experimental
mkdir -p ${CF_EXP_DIR}
cp -r ${STEMBUILD_DIR} ${CF_EXP_DIR}

GO_STEMBUILD_DIR=${CF_EXP_DIR}/stembuild
pushd ${GO_STEMBUILD_DIR}
  echo ***Test Stembuild Code***
  go test

  echo ***Building Stembuild***
  go build
popd

echo ***Copying stembuild to output directory***
cp ${GO_STEMBUILD_DIR}/stembuild ${OUTPUT_DIR}/stembuild-linux-x86_64-${VERSION}


