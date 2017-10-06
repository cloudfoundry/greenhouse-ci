$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:GOPATH=$PWD
$env:PATH = "C:/var/vcap/packages/golang-windows/go/bin;" + $env:PATH

go get github.com/onsi/ginkgo/ginkgo

& "$env:GOPATH/bin/ginkgo.exe" -nodes $env:NODES -r -race -cover -keepGoing -randomizeSuites src/code.cloudfoundry.org/windows2016fs
Exit $LastExitCode
