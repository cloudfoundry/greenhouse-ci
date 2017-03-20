#!/usr/bin/env bash

set -ex

cp -r repo/. updated_repo
cp s3-bucket/tar-*.exe updated_repo/$PATH
