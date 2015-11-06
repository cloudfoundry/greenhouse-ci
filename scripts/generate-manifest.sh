#!/usr/bin/env bash

set -ex

greenhouse-private/$DEPLOYMENT_NAME/generate-cf-diego-manifests.sh
cp /tmp/cf.yml .
cp /tmp/diego.yml .
