#!/bin/bash

set -e

cd buildpack

bundle install

bundle exec buildpack-build --uncached --stack=$STACK --host=$HOST
bundle exec buildpack-build --cached --stack=$STACK --host=$HOST
