$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:PATH = "C:/go/bin;C:/Program Files/Docker;" + $env:PATH

if ((Get-Command "go.exe" -ErrorAction SilentlyContinue) -eq $null) {
  Write-Host "Installing Go"
  Invoke-WebRequest https://storage.googleapis.com/golang/go1.8.1.windows-amd64.msi -OutFile go.msi

  $p = Start-Process -FilePath "msiexec" -ArgumentList "/passive /norestart /i go.msi" -Wait -PassThru

  if($p.ExitCode -ne 0) {
    throw "Golang MSI installation process returned error code: $($p.ExitCode)"
  }

  Write-Host "Installed Go"
}

if ((Get-Command "docker.exe" -ErrorAction SilentlyContinue) -eq $null) {
  Write-Host "Installing Docker"

  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
  Install-Package -Name docker -ProviderName DockerMsftProvider -Force

  Start-Service Docker

  Write-Host "Installed Docker"
}

docker.exe pull microsoft/windowsservercore
$wincTestRootfs = (docker.exe inspect microsoft/windowsservercore | ConvertFrom-Json).GraphDriver.Data.Dir

$wincPath = "$PWD/winc-binary/winc.exe"

cd garden-runc-release

$env:GOPATH = $PWD
$env:PATH = $env:GOPATH + "/bin;C:/go/bin;" + $env:PATH

go.exe install ./src/github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

go build -o noop-network-plugin.exe ./src/code.cloudfoundry.org/garden-integration-tests/plugins/network/noop-network-plugin.go
go build -o noop-image-plugin.exe ./src/code.cloudfoundry.org/garden-integration-tests/plugins/image/noop-image-plugin.go
go build -o gdn.exe ./src/code.cloudfoundry.org/guardian/cmd/gdn

$depotDir = "$env:TEMP\depot"
mkdir $depotDir -Force

Start-Process -NoNewWindow .\gdn.exe -ArgumentList `
  'server `
  --skip-setup `
  --runtime-plugin=$wincPath `
  --image-plugin=.\noop-image-plugin.exe `
  --network-plugin=.\noop-network-plugin.exe `
  --bind-ip=127.0.0.1 `
  --bind-port=7777 `
  --default-rootfs=$wincTestRootfs `
  --depot $depotDir '
  
# wait for server to start up
# and then curl to confirm that it is
Start-Sleep -s 5
$pingResult = (curl -UseBasicParsing "https://127.0.0.1:7777/ping").StatusCode
if ($pingResult -ne 200) {
    throw "Pinging garden server failed with code: $pingResult"
}

cd src/code.cloudfoundry.org/garden-integration-tests
ginkgo.exe -skip=".*" .
Exit $LastExitCode
