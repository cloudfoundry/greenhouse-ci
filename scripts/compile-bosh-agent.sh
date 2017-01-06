#!/bin/bash
set -e -x

export PATH=/usr/local/ruby/bin:/usr/local/go/bin:$PATH
export GOPATH=$(pwd)/gopath

BOSH_AGENT="gopath/src/github.com/cloudfoundry/bosh-agent"
BOSH_AGENT_DEPS="$BOSH_AGENT/integration/windows/fixtures"

pushd gopath/src/github.com/cloudfoundry/bosh-agent
	GOOS=windows ./bin/go build -o bosh-agent.exe main/agent.go
	GOOS=windows ./bin/go build -o pipe.exe jobsupervisor/pipe/main.go
popd

git --git-dir $BOSH_AGENT/.git rev-parse HEAD > compiled-agent/sha

zip -j compiled-agent/agent.zip \
	$BOSH_AGENT/bosh-agent.exe \
	$BOSH_AGENT/pipe.exe \
	$BOSH_AGENT_DEPS/service_wrapper.exe \
  $BOSH_AGENT_DEPS/service_wrapper.xml \
	$BOSH_AGENT_DEPS/service_wrapper.exe.config

zip -j compiled-agent/agent-dependencies.zip \
	$BOSH_AGENT_DEPS/bosh-blobstore-dav.exe \
	$BOSH_AGENT_DEPS/bosh-blobstore-s3.exe \
	$BOSH_AGENT_DEPS/job-service-wrapper.exe \
	$BOSH_AGENT_DEPS/service_wrapper.exe \
	$BOSH_AGENT_DEPS/tar.exe \
	$BOSH_AGENT_DEPS/zlib1.dll
