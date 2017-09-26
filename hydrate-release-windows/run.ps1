$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

./windows2016fs-release/scripts/hydrate.ps1

rm -recurse -force hydrated-release
mv windows2016fs-release hydrated-release
