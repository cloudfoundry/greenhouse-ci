#!/usr/bin/env bash

set -ex

export BOSH_AGENT_DIR="$(pwd)/$BOSH_AGENT_DIR"

pushd "${BOSH_AGENT_DIR}"
  CURRENT_VERSION=$(cat .resource/version)
  mv bosh-agent*.exe bosh-agent.exe
popd

pushd stemcell-builder
  pushd src/github.com/cloudfoundry/bosh-agent
    git checkout "v$CURRENT_VERSION"
  popd
  bundle
  rake package:agent
  mv build/*.zip ../bosh-agent
popd