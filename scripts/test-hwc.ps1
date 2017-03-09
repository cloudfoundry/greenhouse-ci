$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:GOPATH = $PWD
$env:PATH = $env:GOPATH + "/bin;C:/go/bin;" + $env:PATH

if ((Get-Command "go.exe" -ErrorAction SilentlyContinue) -eq $null) {
  Write-Host "Installing Go 1.7.5!"
  Invoke-WebRequest https://storage.googleapis.com/golang/go1.7.5.windows-amd64.msi -OutFile go.msi

  $p = Start-Process -FilePath "msiexec" -ArgumentList "/passive /norestart /i go.msi" -Wait -PassThru

  if($p.ExitCode -ne 0) {
    throw "Golang MSI installation process returned error code: $($p.ExitCode)"
  }

  Write-Host "Go is installed!"
}

cd $env:GOPATH/src/github.com/cloudfoundry-incubator/hwc/hwc

Write-Host "Installing Ginkgo"
go.exe install ./vendor/github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    Write-Error $_
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

ginkgo.exe -r -race -keepGoing
if ($LastExitCode -ne 0) {
    Write-Error $_
    throw "Testing hwc returned error code: $LastExitCode"
}
