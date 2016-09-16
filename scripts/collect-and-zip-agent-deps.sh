#!/usr/bin/env bash

set -ex

DEPS_VERSION=$(cat version/number | tr -d '[[:space:]]')

zip "bosh-agent-deps-zip/agent-dependencies-v$DEPS_VERSION.zip" \
	bosh-blobstore-dav/bosh-blobstore-dav-*.exe \
	bosh-blobstore-s3/bosh-blobstore-s3-*.exe \
	job-service-wrapper/job-service-wrapper-*.exe \
	tar/tar.exe \
	zlib1/zlib1.dll
