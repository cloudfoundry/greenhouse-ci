#!/usr/bin/env bash

set -ex

mkdir diego-release
tar xf diego-github-release/source.tar.gz -C diego-release --strip-components=1
greenhouse-private/$DEPLOYMENT_NAME/generate-cf-diego-manifests.sh
cp /tmp/cf.yml generate-manifest
cp /tmp/diego.yml generate-manifest
