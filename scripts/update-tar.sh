#!/usr/bin/env bash

set -ex

cp -r repo/. updated_repo

for tar_path in $TAR_PATHS; do
	cp s3-bucket/tar-*.exe updated_repo/$tar_path
done
