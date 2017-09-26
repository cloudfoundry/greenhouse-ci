$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

./windows2016fs-release/scripts/hydrate.ps1

cp -Recurse -Force ./windows2016fs-release/* hydrated-release
