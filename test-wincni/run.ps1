$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:GOPATH = $PWD
$env:PATH = $env:GOPATH + "/bin;C:/go/bin;" + $env:PATH

go version

cd $env:GOPATH/src/code.cloudfoundry.org/wincni

Write-Host "Installing Ginkgo"
go install ./vendor/github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

ginkgo -p -r -race -cover -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10
Exit $LastExitCode
