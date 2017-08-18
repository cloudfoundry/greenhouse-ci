$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:GOPATH = $PWD
$env:PATH = $env:GOPATH + "/bin;C:/var/vcap/packages/golang-windows/go/bin;C:/var/vcap/packages/mingw64/mingw64/bin;C:/Program Files/Docker;" + $env:PATH

docker.exe pull $env:TEST_ROOTFS_IMAGE
$env:WINC_TEST_ROOTFS = (docker.exe inspect $env:TEST_ROOTFS_IMAGE | ConvertFrom-Json).GraphDriver.Data.Dir

Set-MpPreference -DisableRealtimeMonitoring $true
Get-ContainerNetwork | Remove-ContainerNetwork -Force

go.exe version

cd $env:GOPATH/src/code.cloudfoundry.org/winc

Write-Host "Installing Ginkgo"
go.exe install ./vendor/github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

ginkgo.exe -p -r -race -cover -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10
$exit = $LastExitCode

Set-MpPreference -DisableRealtimeMonitoring $false

Exit $exit
