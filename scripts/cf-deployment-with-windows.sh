#!/usr/bin/env bash

set -e

CERT_FILE=$(mktemp)
echo "$BOSH_CA_CERT" > $CERT_FILE
export BOSH_CA_CERT=$CERT_FILE

set -x

bosh -n upload-stemcell windows-stemcell/*.tgz

export CF_DEPLOYMENT="$PWD/cf-deployment"
pushd greenhouse-private/$ENVIRONMENT >/dev/null
  $PWD/cf-deploy create

  if ! git diff --exit-code &> /dev/null; then
    git config user.email "pivotal-netgarden-eng@pivotal.io"
    git config user.name "CI (Automated)"
    git add deployment-vars.yml
    git commit -m "Update cf deployment-vars.yml for $ENVIRONMENT"
  fi
popd >/dev/null

cp -a greenhouse-private output/
