#!/bin/bash

set -eu

pushd bosh-deployment
BOSH_DEPLOYMENT_REV=$(git rev-parse HEAD)
popd

cp -R bbl-state/* bbl-state-with-updated-bosh-deployment/

mkdir -p bbl-state-with-updated-bosh-deployment/dev-envs/((BBL_ENV_NAME))/bosh-deployment

cp -R bosh-deployment/* bbl-state-with-updated-bosh-deployment/dev-envs/((BBL_ENV_NAME))/bosh-deployment/

git config user.name "${GIT_COMMIT_USERNAME}"
git config user.email "${GIT_COMMIT_EMAIL}"

git add --all .
git commit -m "Updated bosh_deployment to ${BOSH_DEPLOYMENT_REV}"
