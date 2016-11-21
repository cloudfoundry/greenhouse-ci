#!/usr/bin/env bash

set -ex

export ROOT=$PWD
cd "greenhouse-private/bbl/${ENVIRONMENT}"

export ROOT_CA="/tmp/rootCA.pem"
bbl director-ca-cert > $ROOT_CA
bosh login --ca-cert=$ROOT_CA --environment=$(bbl director-address) --user=$(bbl director-username) --password=$(bbl director-password)

## Generate manifest
cf-filler -dnsname $DOMAIN -recipe cf-deployment/cf-filler/recipe-cf-deployment.yml > vars.yml

bosh -n --ca-cert $ROOT_CA -e $(bbl director-address) upload-stemcell $ROOT/aws-linux-stemcells/stemcell.tgz
bosh -n --ca-cert $ROOT_CA -e $(bbl director-address) upload-stemcell $ROOT/aws-windows-stemcells/stemcell.tgz

bosh -n --ca-cert $ROOT_CA -e $(bbl director-address) -d cf deploy $ROOT/cf-deployment/cf-deployment.yml -l vars.yml -o $ROOT/cf-deployment/opsfiles/disable-router-tls-termination.yml
