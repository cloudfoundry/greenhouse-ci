#!/usr/bin/env bash

set -ex

export BOSH_AGENT_DIR="$(pwd)/$BOSH_AGENT_DIR"

pushd "${BOSH_AGENT_DIR}"
  mv bosh-agent*.exe bosh-agent.exe
popd

pushd stemcell-builder
  bundle
  rake package:agent
  mv build/*.zip ../bosh-agent
popd