#!/usr/bin/env bash

set -eux

pushd stembuild
  make generate-fake-stemcell-automation
popd
