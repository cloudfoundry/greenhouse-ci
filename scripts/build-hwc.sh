#!/usr/bin/env bash

set -e -x

export GOPATH=$PWD

./src/github.com/cloudfoundry-incubator/hwc/scripts/build.sh
