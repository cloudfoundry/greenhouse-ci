#!/usr/bin/env bash

set -ex

# Instead of retooling the job/pipeline, use a copy of the old makefile
mv ci/tasks/build-stembuild-linux/old-Makefile  stembuild/Makefile

VERSION=`cat version/version`
ROOT_DIR=$(pwd)
OUTPUT_DIR=${ROOT_DIR}/output

echo "***Creating GOPATH environment & structure ***"
export GOPATH=$PWD/gopath
export PATH=${GOPATH}/bin:$PATH

CF_INC_DIR=${GOPATH}/src/github.com/cloudfoundry-incubator
STEMBUILD_DIR=${ROOT_DIR}/stembuild
mkdir -p ${CF_INC_DIR}
cp -r ${STEMBUILD_DIR} ${CF_INC_DIR}

mv ${ROOT_DIR}/${STEMCELL_AUTOMATION_ZIP} ${ROOT_DIR}/StemcellAutomation.zip

STEMCELL_AUTOMATION_ZIP=${ROOT_DIR}/StemcellAutomation.zip
GO_STEMBUILD_DIR=${CF_INC_DIR}/stembuild
pushd ${GO_STEMBUILD_DIR}
  echo ***Building Stembuild***
  make STEMCELL_VERSION=${VERSION} AUTOMATION_PATH=${STEMCELL_AUTOMATION_ZIP} build
popd

echo ***Copying stembuild to output directory***
cp ${GO_STEMBUILD_DIR}/out/stembuild ${OUTPUT_DIR}/stembuild-linux-x86_64-${VERSION}

