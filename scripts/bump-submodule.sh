#!/usr/bin/env bash

set -ex

COMMITISH=$(cat commitish/*)

pushd source-repo
  pushd $SUBMODULE_PATH
    git fetch --all
    git checkout $COMMITISH
  popd

  if [ -n "$(git status --porcelain)" ]; then
    git config user.email "pivotal-netgarden-eng@pivotal.io"
    git config user.name "CI (Automated)"
    git add $SUBMODULE_PATH
    git commit -m "Update submodule: $(basename $SUBMODULE_PATH)"
  fi
popd

cp -a source-repo bumped-repo/
