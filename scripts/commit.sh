#!/usr/bin/env bash

set -ex

cp -r repo/* fork_repo
git config --global user.email "pivotal-netgarden-eng@pivotal.io"
git config --global user.name "Greenhouse CI"
git -C fork_repo add -A .
git -C fork_repo commit -m "$MESSAGE"
