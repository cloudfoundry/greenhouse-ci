#!/bin/bash

set -e

cd buildpack

BUNDLE_GEMFILE=cf.Gemfile
bundle install --jobs="$(nproc)" --no-cache

bundle exec buildpack-build --uncached --stack=$STACK --host=$HOST
bundle exec buildpack-build --cached --stack=$STACK --host=$HOST
