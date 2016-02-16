#!/usr/bin/env bash

set -ex

cd cf-release
bosh create release --force --with-tarball --name cf --version 220+dev.`date +"%s"`
mv dev_releases/cf/cf-*.tgz ../created-cf-release
