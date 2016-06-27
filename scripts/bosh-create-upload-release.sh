#!/usr/bin/env bash

bosh_cli() {
  gem install bosh_cli --no-rdoc --no-ri
}

bosh_release() {
  pushd release
  bosh create release --name ${RELEASE_NAME} --force
  bosh target ${BOSH_TARGET_URL}
  bosh login ${BOSH_USER} ${BOSH_PASSWORD}
  bosh -t ${BOSH_TARGET_URL} upload release --rebase
  popd
}

main() {
  set -e
  set -o pipefail

  bosh_cli
  bosh_release
}

main "$@"
