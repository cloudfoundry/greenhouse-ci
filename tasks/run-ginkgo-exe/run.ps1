$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:GOPATH=(Resolve-Path $env:GOPATH).Path

# get tar on the path
$env:PATH="$env:PATH;C:\var\vcap\bosh\bin"

go get github.com/onsi/ginkgo/ginkgo

cd repo
& "$env:GOPATH/bin/ginkgo.exe" -nodes $env:NODES -r -race -keepGoing -randomizeSuites $env:TEST_PATH
Exit $LastExitCode
