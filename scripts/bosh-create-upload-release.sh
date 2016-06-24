#!/usr/bin/env bash

bosh_cli() {
  gem install bosh_cli --no-rdoc --no-ri
}

bosh_release() {
  pushd release
  bosh create release --name ${RELEASE_NAME} --force
  bosh target ${BOSH_TARGET_URL}
  bosh login ${BOSH_USER} ${BOSH_PASSWORD}
  local release_version=$(find dev_releases/*/*+dev*.yml | xargs basename | sed "s/\.yml//" | sed "s/^${RELEASE_NAME}\-//")
  bosh -t ${BOSH_TARGET_URL} -n delete release ${RELEASE_NAME} ${release_version}
  bosh -t ${BOSH_TARGET_URL} upload release
  popd
}

main() {
  set -e
  set -o pipefail

  bosh_cli
  bosh_release
}

main "$@"
