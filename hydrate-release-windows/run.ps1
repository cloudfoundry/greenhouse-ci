$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

cp ./version/version ./windows2016fs-release/IMAGE_TAG

./windows2016fs-release/scripts/hydrate.ps1

cp -Recurse -Force ./windows2016fs-release/* hydrated-release
