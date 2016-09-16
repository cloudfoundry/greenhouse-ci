#!/usr/bin/env bash

set -ex

DEPS_VERSION=$(cat version/number | tr -d '[[:space:]]')

mv tar/tar-*.exe tar/tar.exe
mv zlib1/zlib1-*.dll zlib1/zlib1.dll

zip -j "bosh-agent-deps-zip/agent-dependencies-v$DEPS_VERSION.zip" \
	bosh-blobstore-dav/bosh-blobstore-dav-*.exe \
	bosh-blobstore-s3/bosh-blobstore-s3-*.exe \
	job-service-wrapper/job-service-wrapper-*.exe \
	tar/tar.exe \
	zlib1/zlib1.dll
