#!/bin/bash

set -eEux

export WORKSPACE_DIR=$(pwd)

function commit(){
    git add .
    git commit -m "${BBL_ENV_NAME}: ${GIT_COMMIT_MESSAGE}"
    rsync -a "${WORKSPACE_DIR}/greenhouse-private/" "${WORKSPACE_DIR}/updated-greenhouse-private" # / at the end of private is required
}

git config --global user.name "${GIT_COMMIT_USERNAME}"
git config --global user.email "${GIT_COMMIT_EMAIL}"

mkdir -p "greenhouse-private/dev-envs/${BBL_ENV_NAME}"
pushd "greenhouse-private/dev-envs/${BBL_ENV_NAME}"
    bbl plan

    ln -sf ../../scripts/create-director-override-gcp.sh create-director-override.sh

    rm -rf bosh-deployment jumpbox-deployment
    cp -a "${WORKSPACE_DIR}/bosh-deployment" "${WORKSPACE_DIR}/jumpbox-deployment" .

    trap commit ERR
    bbl up

    commit
popd