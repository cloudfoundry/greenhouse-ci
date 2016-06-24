#!/usr/bin/env bash

bosh_cli() {
  gem install bosh_cli --no-rdoc --no-ri
}

bosh_deploy() {
  bosh target ${BOSH_TARGET_URL} ${BOSH_TARGET_NAME}
  bosh login ${BOSH_USER} ${BOSH_PASSWORD}
  bosh -t ${BOSH_TARGET_NAME} deployment greenhouse-private/bosh-windows-manifests/garden-windows-${BOSH_TARGET_NAME}.yml
  bosh -t ${BOSH_TARGET_NAME} -n deploy
}

main() {
  set -e
  set -o pipefail

  bosh_cli
  bosh_deploy
}

main "$@"
