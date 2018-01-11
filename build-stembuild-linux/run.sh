#!/usr/bin/env bash

set -ex

VERSION=`cat stembuild-version/version`
ROOT_DIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
OUTPUT_DIR=${ROOT_DIR}/output

echo ***Installing VMWare OVF Tools***
chmod +x ./ovftool/VMware-ovftool-4.2.0-5965791-lin.x86_64.bundle
./ovftool/VMware-ovftool-4.2.0-5965791-lin.x86_64.bundle --eulas-agreed --required

echo ***Generating librsync sources***
LIBRSYNC_DIR=${ROOT_DIR}/librsync
LIBRSYNC_BUILD_DIR=${LIBRSYNC_DIR}/build
LIBRSYNC_INSTALL_DIR=${LIBRSYNC_DIR}/install
mkdir ${LIBRSYNC_BUILD_DIR}
mkdir ${LIBRSYNC_INSTALL_DIR}

pushd ${LIBRSYNC_BUILD_DIR}
  cmake -DCMAKE_INSTALL_PREFIX=${LIBRSYNC_INSTALL_DIR} -DCMAKE_BUILD_TYPE=release -G "Unix Makefiles" ..
  make
popd

echo ***Copying librsync sources into stembuild***
STEMBUILD_DIR=${ROOT_DIR}/stembuild
STEMBUILD_RDIFF_DIR=${STEMBUILD_DIR}/rdiff

pushd ${STEMBUILD_RDIFF_DIR}
  cp ${LIBRSYNC_DIR}/src/* .
  cp ${LIBRSYNC_BUILD_DIR}/src/* .
  rm rdiff.c
popd

pushd ${STEMBUILD_DIR}
  export GOPATH=$PWD
  export PATH=${GOPATH}/bin:$PATH

  echo ***Test Stembuild Code***
  go test

  echo ***Building Stembuild***
  go build
popd

***Copying stembuild to output directory***
cp ${STEMBUILD_DIR}/stembuild ${OUTPUT_DIR}/stembuild-linux-x86_64-${VERSION}


