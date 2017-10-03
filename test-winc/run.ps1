$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:PATH = $env:GOPATH + "/bin;C:/var/vcap/packages/golang-windows/go/bin;C:/var/vcap/packages/mingw64/mingw64/bin;" + $env:PATH

go.exe version

push-location windows2016fs-release
    powershell ./scripts/hydrate
    $env:GOPATH = $PWD
    go build -o extract.exe oci-image/cmd/extract
    $rootfsTgz = (get-item .\blobs\windows2016fs\windows2016fs-*.tgz).FullName
    $topLayer = (.\extract.exe $rootfsTgz "c:\ProgramData\windows2016fs\layers")
pop-location

$env:WINC_TEST_ROOTFS=$topLayer
$env:GOPATH = $PWD

Set-MpPreference -DisableRealtimeMonitoring $true
Get-ContainerNetwork | Remove-ContainerNetwork -Force

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
