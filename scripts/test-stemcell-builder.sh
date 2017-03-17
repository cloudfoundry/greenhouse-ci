#!/usr/bin/env bash

set -ex

cd stemcell-builder
bundle install
bundle exec rspec

