#!/usr/bin/env bash

set -e

CERT_FILE=$(mktemp)
echo "$BOSH_CA_CERT" > $CERT_FILE
export BOSH_CA_CERT=$CERT_FILE

set -x

export CF_DEPLOYMENT="$PWD/cf-deployment"
pushd greenhouse-private >/dev/null
  $PWD/$ENVIRONMENT/cf/deploy create

  if [ -n "$(git status --porcelain)" ]; then
    git config user.email "pivotal-netgarden-eng@pivotal.io"
    git config user.name "CI (Automated)"
    git add $PWD/$ENVIRONMENT/cf/creds.yml
    git commit -m "Update cf creds.yml for $ENVIRONMENT"
  fi
popd >/dev/null

cp -a greenhouse-private output/
