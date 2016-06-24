#!/usr/bin/env bash

main() {
  set -e
  set -o pipefail

  gem install bosh_cli --no-rdoc --no-ri
  bosh target ${BOSH_TARGET_URL} ${BOSH_TARGET_NAME}
  bosh login ${BOSH_USER} ${BOSH_PASSWORD}
  bosh -t ${BOSH_TARGET_NAME} -n delete deployment garden-windows
}

main "$@"
