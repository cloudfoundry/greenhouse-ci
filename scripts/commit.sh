#!/usr/bin/env bash

set -ex

cp -r repo/* fork_repo
git -C fork_repo add -A .
git -C fork_repo commit -m "$MESSAGE"
