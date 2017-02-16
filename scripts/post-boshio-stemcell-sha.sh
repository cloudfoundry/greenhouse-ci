#!/usr/bin/env bash

set -e

stemcell_filename=$(basename sha/*.sha .sha)
checksum=$(cat sha/*.sha)

curl -X POST \
    --fail \
    -d "sha1=${checksum}" \
    -H "Authorization: bearer ${BOSHIO_TOKEN}" \
    "https://bosh.io/checksums/${stemcell_filename}"
