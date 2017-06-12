$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

go get github.com/onsi/ginkgo/ginkgo

$env:GOPATH/bin/ginkgo.exe -p -r -race -cover -keepGoing -randomizeSuites $env:TEST_PATH
Exit $LastExitCode
