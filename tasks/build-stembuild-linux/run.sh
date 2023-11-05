#!/usr/bin/env bash
set -eu -o pipefail
set -x

ROOT_DIR=$(pwd)

VERSION=$(cat version/version)
STEMBUILD_DIR="${ROOT_DIR}/stembuild"
OUTPUT_DIR="${ROOT_DIR}/output"

NON_GLOB_STEMCELL_AUTOMATION_ZIP="$(ls "${ROOT_DIR}/${STEMCELL_AUTOMATION_ZIP}")"

# Instead of retooling the job/pipeline, use a copy of the old makefile
mv ci/tasks/build-stembuild-linux/old-Makefile  "${STEMBUILD_DIR}/Makefile"

pushd "${STEMBUILD_DIR}"
  echo '***Building Stembuild***'
  make \
    CGO_ENABLED=0 \
    STEMCELL_VERSION="${VERSION}" \
    AUTOMATION_PATH="${NON_GLOB_STEMCELL_AUTOMATION_ZIP}" \
    build
popd

echo '***Copying stembuild to output directory***'
cp "${STEMBUILD_DIR}/out/stembuild" "${OUTPUT_DIR}/stembuild-linux-x86_64-${VERSION}"
