#!/usr/bin/env bash

set -e

echo "$GITHUB_SSH_KEY" > github_private_key.pem
chmod 0600 github_private_key.pem
eval $(ssh-agent)
ssh-add github_private_key.pem > /dev/null

set -x

cp cf-vars/deployment-vars.yml greenhouse-private/$ENVIRONMENT/
pushd greenhouse-private/$ENVIRONMENT >/dev/null
  if ! git diff --exit-code; then
    git config user.email "pivotal-netgarden-eng@pivotal.io"
    git config user.name "CI (Automated)"
    git add deployment-vars.yml
    git commit -m "Update cf-vars for $ENVIRONMENT"
    git push origin HEAD:master
  fi
popd >/dev/null
