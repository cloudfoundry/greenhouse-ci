$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

push-location repo
  git checkout .
  git submodule foreach --recursive git checkout .
pop-location

cp -recurse repo\* cleaned-repo\
