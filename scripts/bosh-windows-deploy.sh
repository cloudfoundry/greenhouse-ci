#!/usr/bin/env bash

bosh_cli() {
  gem install bosh_cli --no-rdoc --no-ri
}

bosh_cert() {
  CA_CERT=""
  if [[ -n "${BOSH_TARGET_CERT}" ]]; then
    echo -n "${BOSH_TARGET_CERT}" > /tmp/cert
    chmod 600 /tmp/cert
    CA_CERT="--ca-cert /tmp/cert"
  fi
}

bosh_deploy() {
  bosh -n ${CA_CERT} target ${BOSH_TARGET_URL} ${BOSH_TARGET_NAME}
  printf "${BOSH_USER}\n${BOSH_PASSWORD}" | bosh login
  bosh -t ${BOSH_TARGET_NAME} deployment greenhouse-private/bosh-windows-manifests/garden-windows-${BOSH_TARGET_NAME}.yml
  bosh -t ${BOSH_TARGET_NAME} -n deploy
}

main() {
  set -e
  set -o pipefail

  bosh_cli
  bosh_cert
  bosh_deploy
}

main "$@"
