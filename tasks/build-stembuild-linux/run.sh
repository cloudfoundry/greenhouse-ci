#!/usr/bin/env bash
set -eu -o pipefail
set -x

ROOT_DIR=$(pwd)

VERSION=$(cat version/version)
STEMBUILD_DIR="${ROOT_DIR}/stembuild"
OUTPUT_DIR="${ROOT_DIR}/output"

INPUT_ZIP_GLOB="${ROOT_DIR}"/${STEMCELL_AUTOMATION_ZIP}
# `old-Makefile` does not rename `AUTOMATION_PATH` so this filename must
# match the expected go:empbed file in `stembuild/assets/stemcell_automation.go`
RENAMED_ZIP_PATH="${ROOT_DIR}/StemcellAutomation.zip"
cp ${INPUT_ZIP_GLOB} "${RENAMED_ZIP_PATH}"

# Instead of retooling the job/pipeline, use a copy of the old makefile
cp ci/tasks/build-stembuild-linux/old-Makefile  "${STEMBUILD_DIR}/Makefile"

pushd "${STEMBUILD_DIR}"
  echo '***Building Stembuild***'
  make \
    CGO_ENABLED=0 \
    STEMCELL_VERSION="${VERSION}" \
    AUTOMATION_PATH="${RENAMED_ZIP_PATH}" \
    build
popd

echo '***Copying stembuild to output directory***'
cp "${STEMBUILD_DIR}/out/stembuild" "${OUTPUT_DIR}/stembuild-linux-x86_64-${VERSION}"
