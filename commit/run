#!/usr/bin/env bash

set -ex

cp -r destination_repo/. destination_repo_with_commit
cp -r source_repo/* destination_repo_with_commit
git config --global user.email "pivotal-netgarden-eng@pivotal.io"
git config --global user.name "Greenhouse CI"
git -C destination_repo_with_commit add -A .
git -C destination_repo_with_commit commit -m "$MESSAGE"
