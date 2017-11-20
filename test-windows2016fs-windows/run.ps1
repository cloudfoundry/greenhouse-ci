$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:GOPATH=$PWD

go get github.com/onsi/ginkgo/ginkgo

& "$env:GOPATH/bin/ginkgo.exe" -nodes $env:NODES -r -race -keepGoing -randomizeSuites src/code.cloudfoundry.org/windows2016fs
Exit $LastExitCode
