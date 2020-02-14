#!/usr/bin/env bash

set -euo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cp ./lgpo/LGPO-*.zip ./lgpo/LGPO.zip
pushd ./stemcell-automation
ruby mk-deps.rb $DIR/dependency_sources.json | jq . > ../deps-file/deps.json
