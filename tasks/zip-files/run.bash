#!/usr/bin/env bash

set -euo pipefail

cp open-ssh/OpenSSH-Win64.zip bosh-psmodules/bosh-psmodules.zip bosh-agent/agent.zip deps-file/deps.json stembuild/stemcell-automation
zip -rj StemcellAutomation.zip stembuild/stemcell-automation -x \*.Tests.\* *NOTICE
cp StemcellAutomation.zip "zip-file/StemcellAutomation-"`date +"%s"`.zip
