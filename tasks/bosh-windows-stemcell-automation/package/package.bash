#!/usr/local/env bash

set -euo pipefail

cp ./lgpo/LGPO-*.zip ./lgpo/LGPO.zip
pushd ./stemcell-automation
ruby mk-deps.rb ./dependency_sources.json | jq . > deps.json
cat deps.json
