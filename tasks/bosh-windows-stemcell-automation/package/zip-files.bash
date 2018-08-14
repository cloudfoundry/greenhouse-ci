#!/usr/bin/env bash

set -euo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

pushd stemcell-automation
file_sources=`jq -r '.[] | select(.exclude_from_zip != true) | .file_source' $DIR/dependency_sources.json`
cp $file_sources ../deps-file/deps.json .
zip StemcellAutomation.zip *
cp StemcellAutomation.zip ../zip-file/StemcellAutomation-`date +"%s"`.zip
