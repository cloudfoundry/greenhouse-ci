#!/bin/bash

set -e -x -u

version=$(cat version/number)

pushd garden-windows-bosh-release
  bosh --parallel 4 -n create release --with-tarball --version "$version" --force

  mv dev_releases/garden-windows/*.tgz ../garden-windows-bosh-release-tarball
popd
