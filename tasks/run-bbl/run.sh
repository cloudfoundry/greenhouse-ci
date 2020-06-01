#!/bin/bash

set -eEux

export WORKSPACE_DIR=$(pwd)
apt install rsync -y

function commit(){
    git add .
    git commit -m "${BBL_ENV_NAME}: ${GIT_COMMIT_MESSAGE}"
    rsync -a "${WORKSPACE_DIR}/greenhouse-private/" "${WORKSPACE_DIR}/updated-greenhouse-private" # / at the end of private is required
}


function loadSecrets() {
  case "${BBL_IAAS}" in
  gcp)
#  echo "${BBL_GCP_SERVICE_ACCOUNT_KEY}" > gcp-service-account-key.json
  ;;
  aws)
  echo ${BBL_AWS_ACCESS_KEY_ID} > aws-access-key-id
#  echo ${BBL_AWS_SECRET_ACCESS_KEY} > aws-secret-access-key
  ;;
  azure)
#  echo ${AZURE_DEV_JSON} > azure-client-credentials.json
  echo ${BBL_AZURE_SUBSCRIPTION_ID} > azure-dev-subscription-id
  echo ${BBL_AZURE_TENANT_ID} > azure-dev-tenant-id
  echo ${BBL_AZURE_CLIENT_ID} > azure-dev-client-id
  ;;
  esac
}

git config --global user.name "${GIT_COMMIT_USERNAME}"
git config --global user.email "${GIT_COMMIT_EMAIL}"

mkdir -p "greenhouse-private/dev-envs/${BBL_ENV_NAME}"
pushd "greenhouse-private/dev-envs/${BBL_ENV_NAME}"
    loadSecrets

    bbl plan

    ln -sf ../../scripts/create-director-override-${BBL_IAAS}.sh create-director-override.sh

    rm -rf bosh-deployment jumpbox-deployment
    cp -a "${WORKSPACE_DIR}/bosh-deployment" "${WORKSPACE_DIR}/jumpbox-deployment" .

    trap commit ERR
    bbl up

    commit
popd
