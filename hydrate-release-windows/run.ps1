$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

./windows2016fs-release/scripts/hydrate.ps1

Get-ChildItem -Force windows2016fs-release\* | Move-Item -Destination hydrated-release
