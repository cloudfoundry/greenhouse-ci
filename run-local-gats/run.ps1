$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

function Kill-Garden
{
  Get-Process | foreach { if ($_.name -eq "gdn") { kill -Force $_.Id } }
}

$env:PATH = "C:/var/vcap/packages/golang-windows/go/bin;C:/var/vcap/bosh/bin;" + $env:PATH

go version

push-location windows2016fs-release
    $env:GOPATH = $PWD

    $image_tag = (cat IMAGE_TAG)
    mkdir -Force "blobs/windows2016fs"
    go run src/oci-image/cmd/hydrate/main.go -image "cloudfoundry/windows2016fs" -outputDir "blobs/windows2016fs" -tag $image_tag
    if ($LastExitCode -ne 0) {
        throw "Download image process returned error code: $LastExitCode"
    }

    go build -o extract.exe oci-image/cmd/extract
    if ($LastExitCode -ne 0) {
        throw "Build extract process returned error code: $LastExitCode"
    }
    $rootfsTgz = (get-item .\blobs\windows2016fs\windows2016fs-*.tgz).FullName
    $wincTestRootfs = (.\extract.exe $rootfsTgz "c:\ProgramData\windows2016fs\layers")
    if ($LastExitCode -ne 0) {
        throw "Extract process returned error code: $LastExitCode"
    }
pop-location

$env:GOPATH = "$PWD/garden-runc-release"
$env:PATH= "$env:GOPATH/bin;" + $env:PATH

Set-MpPreference -DisableRealtimeMonitoring $true
Get-ContainerNetwork | Remove-ContainerNetwork -Force

$wincPath = "$PWD/winc-binary/winc.exe"
$wincNetworkPath = "$PWD/winc-network-binary/winc-network.exe"
$wincImagePath = "$PWD/winc-image-binary/winc-image.exe"
$nstarPath = "$PWD/nstar-binary/nstar.exe"

push-location garden-runc-release
  go install ./src/github.com/onsi/ginkgo/ginkgo
  if ($LastExitCode -ne 0) {
      throw "Ginkgo installation process returned error code: $LastExitCode"
  }

  go build -o gdn.exe ./src/code.cloudfoundry.org/guardian/cmd/gdn
  if ($LastExitCode -ne 0) {
      throw "Building gdn.exe process returned error code: $LastExitCode"
  }

  # Kill any existing garden servers
  Kill-Garden

  $depotDir = "$env:TEMP\depot"
  Remove-Item -Recurse -Force -ErrorAction Ignore $depotDir
  mkdir $depotDir -Force

  $env:GARDEN_ADDRESS = "127.0.0.1"
  $env:GARDEN_PORT = "8888"

  $tarBin = (get-command tar.exe).source

  $imageRoot="C:\var\vcap\packages\winc-image\rootfs"

  Start-Process `
    -NoNewWindow `
    -RedirectStandardOutput gdn.out.log `
    -RedirectStandardError gdn.err.log `
    .\gdn.exe -ArgumentList `
    "server `
    --skip-setup `
    --runtime-plugin=$wincPath `
    --image-plugin=$wincImagePath `
    --image-plugin-extra-arg=--store=$imageRoot `
    --network-plugin=$wincNetworkPath `
    --bind-ip=$env:GARDEN_ADDRESS `
    --bind-port=$env:GARDEN_PORT `
    --default-rootfs=$wincTestRootfs `
    --nstar-bin=$nstarPath `
    --tar-bin=$tarBin `
    --depot $depotDir `
    --runc-root=$imageRoot `
    --log-level=debug"

  # wait for server to start up
  # and then curl to confirm that it is
  Start-Sleep -s 5
  $pingResult = (curl -UseBasicParsing "http://${env:GARDEN_ADDRESS}:${env:GARDEN_PORT}/ping").StatusCode
  if ($pingResult -ne 200) {
      throw "Pinging garden server failed with code: $pingResult"
  }

  Push-Location src/code.cloudfoundry.org/garden-integration-tests
    ginkgo -p -randomizeSuites -noisyPendings=false
  Pop-Location
Pop-Location
$ExitCode="$LastExitCode"

Kill-Garden

Set-MpPreference -DisableRealtimeMonitoring $false

if ($ExitCode -ne 0) {
  echo "gdn.exe STDOUT"
  Get-Content garden-runc-release/gdn.out.log
  echo "gdn.exe STDERR"
  Get-Content garden-runc-release/gdn.err.log
  Exit $ExitCode
}
