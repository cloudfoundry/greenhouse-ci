#!/bin/bash

set -e -x

export GOPATH=$PWD

./src/github.com/cloudfoundry-incubator/hwc/scripts/build.sh
