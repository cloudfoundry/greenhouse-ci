#!/usr/bin/env bash

set -ex

greenhouse-private/$DEPLOYMENT_NAME/generate-cf-diego-manifests.sh
cp /tmp/cf.yml generate-manifest
cp /tmp/diego.yml generate-manifest
