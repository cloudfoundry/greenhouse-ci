$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

Remove-Item -Recurse -Force garden-runc-release/src/code.cloudfoundry.org/guardian
write-host "Copying guardian fork...."
Copy-Item  -Recurse guardian garden-runc-release/src/code.cloudfoundry.org/

Remove-Item -Recurse -Force garden-runc-release/src/code.cloudfoundry.org/garden-integration-tests
write-host "Copying GATS fork...."
Copy-Item  -Recurse garden-integration-tests garden-runc-release/src/code.cloudfoundry.org/

write-host "Copying into garden-runc-release-forks"
Copy-Item  -Recurse garden-runc-release/* garden-runc-release-forks
