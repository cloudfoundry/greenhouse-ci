$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:PATH = "C:/var/vcap/packages/golang-windows/go/bin;C:/var/vcap/packages/mingw64/mingw64/bin;" + $env:PATH

go.exe version

push-location windows2016fs-release
    $env:GOPATH = $PWD

    $image_tag = $env:TEST_CONTAINER_IMAGE_TAG
    if ($image_tag -eq "") {
        $image_tag = (cat IMAGE_TAG)
    }
    mkdir -Force "blobs/windows2016fs"
    go run src/oci-image/cmd/hydrate/main.go -image "cloudfoundry/windows2016fs" -outputDir "blobs/windows2016fs" -tag $image_tag

    go build -o extract.exe oci-image/cmd/extract
    $rootfsTgz = (get-item .\blobs\windows2016fs\windows2016fs-*.tgz).FullName
    $topLayer = (.\extract.exe $rootfsTgz "c:\ProgramData\windows2016fs\layers")
pop-location

$env:WINC_TEST_ROOTFS=$topLayer
$env:GOPATH = $PWD
$env:PATH="$env:GOPATH\bin;" +$env:PATH

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
