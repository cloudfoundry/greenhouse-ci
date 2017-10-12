$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:PATH = "C:/var/vcap/packages/golang-windows/go/bin;C:/var/vcap/packages/mingw64/mingw64/bin;" + $env:PATH

go.exe version

$env:GOPATH = $PWD
push-location src/code.cloudfoundry.org/windows2016fs
  $image_tag = $env:TEST_CONTAINER_IMAGE_TAG
  if ($image_tag -eq $null -or $image_tag -eq "") {
      $image_tag = (cat IMAGE_TAG)
  }
  $output_dir = "temp/windows2016fs"
  mkdir -Force $output_dir
  go run ./cmd/hydrate/main.go -image "cloudfoundry/windows2016fs" -outputDir $output_dir -tag $image_tag
  if ($LastExitCode -ne 0) {
      throw "Download image process returned error code: $LastExitCode"
  }

  go build -o extract.exe ./cmd/extract
  if ($LastExitCode -ne 0) {
      throw "Build extract process returned error code: $LastExitCode"
  }
  $rootfsTgz = (get-item "$output_dir\windows2016fs-*.tgz").FullName
  $env:WINC_TEST_ROOTFS = (.\extract.exe $rootfsTgz "c:\ProgramData\windows2016fs\layers")
  if ($LastExitCode -ne 0) {
      throw "Extract process returned error code: $LastExitCode"
  }
pop-location

$env:GOPATH = $PWD
$env:PATH="$env:GOPATH\bin;" +$env:PATH

Set-MpPreference -DisableRealtimeMonitoring $true

if ($env:INSIDER_PREVIEW -eq $null -or $env:INSIDER_PREVIEW -eq "") {
    Get-ContainerNetwork | Remove-ContainerNetwork -Force
} else {
  $config = '{"name": "winc-nat", "insider_preview": true}'
  set-content -path "$env:TEMP\interface.json" -value $config
  go run src/code.cloudfoundry.org/winc/cmd/winc-network --action delete --configFile "$env:TEMP/interface.json"
}

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
