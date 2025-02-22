#!/usr/bin/env bash

set -euo pipefail

OPENSSH_ZIP=open-ssh/OpenSSH-Win64.zip \
BOSH_PSMODULES_ZIP=bosh-psmodules/bosh-psmodules.zip \
AGENT_ZIP=bosh-agent/agent.zip \
DEPS_JSON=deps-file/deps.json \
stembuild/bin/build-stemcell-automation-zip.sh

cp stembuild/assets/StemcellAutomation.zip "zip-file/StemcellAutomation-"`date +"%s"`.zip
