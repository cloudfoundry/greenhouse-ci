$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:GOPATH = $PWD
$env:PATH = $env:GOPATH + "/bin;C:/go/bin;C:/Program Files/Docker;" + $env:PATH

docker.exe pull $env:TEST_ROOTFS_IMAGE
$env:WINC_TEST_ROOTFS = (docker.exe inspect $env:TEST_ROOTFS_IMAGE | ConvertFrom-Json).GraphDriver.Data.Dir

go.exe version

cd $env:GOPATH/src/code.cloudfoundry.org/winc

Write-Host "Installing Ginkgo"
go.exe install ./vendor/github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

Set-MpPreference -DisableRealtimeMonitoring $true

ginkgo.exe -p -r -race -cover -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10
$exit = $LastExitCode

Set-MpPreference -DisableRealtimeMonitoring $false

Exit $exit
