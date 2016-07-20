#!/usr/bin/env bash

bosh_cli() {
  gem install bosh_cli --no-rdoc --no-ri
}

bosh_release() {
  pushd release
  bosh --parallel 4 -n create release --with-tarball --version $version --force
  mv dev_releases/garden-windows/*.tgz ../garden-windows-output/
  popd
}

main() {
  set -e
  set -o pipefail

  bosh_cli
  bosh_release
}

main "$@"
