$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:GOPATH=(Resolve-Path $env:GOPATH).Path

$env:PATH = "C:/var/vcap/packages/golang-windows/go/bin;" + $env:PATH

go get github.com/onsi/ginkgo/ginkgo

cd repo
& "$env:GOPATH/bin/ginkgo.exe" -p -r -race -cover -keepGoing -randomizeSuites $env:TEST_PATH
Exit $LastExitCode
