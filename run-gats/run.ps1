$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

function Kill-Garden
{
  Get-Process | foreach { if ($_.name -eq "gdn") { kill -Force $_.Id } }
}

$env:GOPATH = "$PWD/garden-runc-release"
$env:PATH = $env:GOPATH + "/bin;C:/go/bin;C:/Program Files/Docker;" + $env:PATH

if ((Get-Command "go.exe" -ErrorAction SilentlyContinue) -eq $null) {
  Write-Host "Installing Go"
  Invoke-WebRequest https://storage.googleapis.com/golang/go1.8.3.windows-amd64.msi -OutFile go.msi

  $p = Start-Process -FilePath "msiexec" -ArgumentList "/passive /norestart /i go.msi" -Wait -PassThru

  if($p.ExitCode -ne 0) {
    throw "Golang MSI installation process returned error code: $($p.ExitCode)"
  }

  Write-Host "Installed Go"
}
go.exe version

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

Push-Location garden-runc-release

go.exe install ./src/github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}
go build -o noop-network-plugin.exe ./src/code.cloudfoundry.org/garden-integration-tests/plugins/network/noop-network-plugin.go
if ($LastExitCode -ne 0) {
    throw "Building network plugin process returned error code: $LastExitCode"
}
go build -o noop-image-plugin.exe ./src/code.cloudfoundry.org/garden-integration-tests/plugins/image/noop-image-plugin.go
if ($LastExitCode -ne 0) {
    throw "Building image plugin process returned error code: $LastExitCode"
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

Start-Process `
  -NoNewWindow `
  -RedirectStandardOutput gdn.out.log `
  -RedirectStandardError gdn.err.log `
  .\gdn.exe -ArgumentList `
  "server `
  --skip-setup `
  --runtime-plugin=$wincPath `
  --image-plugin=.\noop-image-plugin.exe `
  --network-plugin=.\noop-network-plugin.exe `
  --bind-ip=$env:GARDEN_ADDRESS `
  --bind-port=$env:GARDEN_PORT `
  --default-rootfs=$wincTestRootfs `
  --depot $depotDir"

# wait for server to start up
# and then curl to confirm that it is
Start-Sleep -s 5
$pingResult = (curl -UseBasicParsing "http://${env:GARDEN_ADDRESS}:${env:GARDEN_PORT}/ping").StatusCode
if ($pingResult -ne 200) {
    throw "Pinging garden server failed with code: $pingResult"
}

Push-Location src/code.cloudfoundry.org/garden-integration-tests
ginkgo.exe -p -nodes=8 -failOnPending -randomizeSuites .
Pop-Location
Pop-Location
$ExitCode="$LastExitCode"

Kill-Garden

# ginkgo exits 197 if any tests are focused but they all passed
if ($ExitCode -eq 197) {
  Exit 0
} Else {
  echo "gdn.exe STDOUT"
  Get-Content gdn.out.log
  echo "gdn.exe STDERR"
  Get-Content gdn.err.log
  Exit $ExitCode
}
