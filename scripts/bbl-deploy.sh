#!/usr/bin/env bash

set -ex

export ROOT=$PWD
cp -r greenhouse-private/. greenhouse-private-output

pushd "greenhouse-private-output/bbl/${ENVIRONMENT}"

export ROOT_CA="/tmp/rootCA.pem"
bbl director-ca-cert > $ROOT_CA
bosh login --ca-cert=$ROOT_CA --environment=$(bbl director-address) --user=$(bbl director-username) --password=$(bbl director-password)

## Generate manifest
cf-filler -dnsname $DOMAIN -recipe $ROOT/cf-deployment/cf-filler/recipe-cf-deployment.yml > vars.yml

bosh -n --ca-cert $ROOT_CA -e $(bbl director-address) upload-stemcell $ROOT/aws-linux-stemcell/stemcell.tgz
WINDOWS_STEMCELL=$(basename $ROOT/aws-windows-stemcell/*.tgz)
bosh -n --ca-cert $ROOT_CA -e $(bbl director-address) upload-stemcell "$ROOT/aws-windows-stemcell/$WINDOWS_STEMCELL"

bosh -n --ca-cert $ROOT_CA -e $(bbl director-address) -d cf deploy $ROOT/cf-deployment/cf-deployment.yml -l vars.yml -o $ROOT/cf-deployment/opsfiles/disable-router-tls-termination.yml

echo "----- Set git identity"
git config user.email "cf-netgarden-eng@pivotal.io"
git config user.name "CI (Automated)"

git commit -am ":rocket: Update ${ENVIRONMENT}"
popd

