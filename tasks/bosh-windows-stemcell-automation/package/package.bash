#!/usr/local/env bash

set -euo pipefail

cp ./open-ssh/OpenSSH-Win64.zip ./stemcell-automation
cp ./stemcell-builder/bosh-psmodules.zip ./stemcell-automation
cp ./stemcell-builder/agent.zip ./stemcell-automation
cp ./lgpo/LGPO-*.zip ./stemcell-automation/LGPO.zip
pushd ./stemcell-automation
./mk-deps.sh
cat deps.json
