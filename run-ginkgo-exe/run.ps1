Set-PSDebug -trace 1            # "set -x"
Set-PSDebug -strict             # "set -u"
$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

echo "OLD GOPATH: [$env:GOPATH]"
$env:GOPATH=(Get-ChildItem $env:GOPATH).FullName
echo "NEW GOPATH: [$env:GOPATH]"

go get github.com/onsi/ginkgo/ginkgo

$env:GOPATH/bin/ginkgo.exe -p -r -race -cover -keepGoing -randomizeSuites $env:TEST_PATH
Exit $LastExitCode
