#!/usr/bin/env bash
set -eu -o pipefail
set -x

BOSH_AGENT_DIR="$(pwd)/${BOSH_AGENT_DIR}"
export BOSH_AGENT_DIR
pushd "${BOSH_AGENT_DIR}"
  BOSH_AGENT_VERSION=$(cat .resource/version)
  mv bosh-agent-pipe*.exe pipe.exe
  mv bosh-agent*.exe bosh-agent.exe
popd

pushd stemcell-builder
  pushd src/github.com/cloudfoundry/bosh-agent
    git fetch
    git checkout "v${BOSH_AGENT_VERSION}"
  popd

  bundle install --without test

  rake package:agent

  mv build/*.zip ../bosh-agent
popd
