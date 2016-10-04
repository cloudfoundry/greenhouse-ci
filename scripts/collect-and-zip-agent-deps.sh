#!/usr/bin/env bash

set -ex

DEPS_VERSION=$(cat version/number | tr -d '[[:space:]]')

mv tar/tar{-*,}.exe
mv zlib1/zlib1{-*,}.dll
mv winsw-exe/{winsw-*,job-service-wrapper}.exe
mv bosh-blobstore-dav/{davcli-*-windows-amd64,bosh-blobstore-dav}.exe
mv bosh-blobstore-s3/{s3cli-*-windows-amd64,bosh-blobstore-s3}.exe

zip -j "bosh-agent-deps-zip/agent-dependencies-v$DEPS_VERSION.zip" \
	bosh-blobstore-dav/*.exe \
	bosh-blobstore-s3/*.exe \
	winsw-exe/*.exe \
	tar/*.exe \
	zlib1/*.dll
