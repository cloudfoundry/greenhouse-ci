$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:GOPATH = $PWD
$env:PATH = $env:GOPATH + "/bin;C:/go/bin;C:/Program Files/Docker;" + $env:PATH

if ((Get-Command "docker.exe" -ErrorAction SilentlyContinue) -eq $null) {
  Write-Host "Installing Docker"

  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
  Install-Package -Name docker -ProviderName DockerMsftProvider -Force

  Start-Service Docker

  Write-Host "Installed Docker"
}

docker.exe pull $env:TEST_ROOTFS_IMAGE
$env:WINC_TEST_ROOTFS = (docker.exe inspect $env:TEST_ROOTFS_IMAGE | ConvertFrom-Json).GraphDriver.Data.Dir

if ((Get-Command "go.exe" -ErrorAction SilentlyContinue) -eq $null) {
  Write-Host "Installing Go"
  Invoke-WebRequest https://storage.googleapis.com/golang/go1.8.1.windows-amd64.msi -OutFile go.msi

  $p = Start-Process -FilePath "msiexec" -ArgumentList "/passive /norestart /i go.msi" -Wait -PassThru

  if($p.ExitCode -ne 0) {
    throw "Golang MSI installation process returned error code: $($p.ExitCode)"
  }

  Write-Host "Installed Go"
}

go.exe version

cd $env:GOPATH/src/code.cloudfoundry.org/winc

Write-Host "Installing Ginkgo"
go.exe install ./vendor/github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

ginkgo.exe -r -race -cover -keepGoing -randomizeSuites
Exit $LastExitCode
