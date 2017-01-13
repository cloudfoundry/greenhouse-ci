#!/usr/bin/env bash

set -e

CERT_FILE=$(mktemp)
echo "$BOSH_CA_CERT" > $CERT_FILE
export BOSH_CA_CERT=$CERT_FILE

set -x

bosh -n upload-stemcell vsphere-windows-stemcell/*.tgz

./greenhouse-private/$ENVIRONMENT/cf/deploy create

cp ./greenhouse-private/$ENVIRONMENT/cf/deployment-vars.yml ./cf-vars/deployment-vars.yml
