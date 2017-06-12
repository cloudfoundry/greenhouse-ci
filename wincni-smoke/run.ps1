$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

$env:GOPATH = "$PWD\cf-networking-release"
$env:PATH = $env:GOPATH + "\bin;C:\go\bin;" + $env:PATH

if ((Get-Command "go.exe" -ErrorAction SilentlyContinue) -eq $null) {
  Write-Host "Installing Go"
  Invoke-WebRequest https://storage.googleapis.com/golang/go1.8.3.windows-amd64.msi -OutFile go.msi

  $p = Start-Process -FilePath "msiexec" -ArgumentList "/passive /norestart /i go.msi" -Wait -PassThru

  if($p.ExitCode -ne 0) {
    throw "Golang MSI installation process returned error code: $($p.ExitCode)"
  }

  Write-Host "Installed Go"
}

go version

Write-Host "Installing garden-external-networker"
go install garden-external-networker
if ($LastExitCode -ne 0) {
    throw "garden-external-networker installation process returned error code: $LastExitCode"
}

Write-Host "creating directories"
Remove-Item -Recurse -Force -ErrorAction Ignore cni-config
mkdir -Force cni-config
add-content ".\\cni-config\\wincni.conf" '{"type": "wincni", "cniVersion": "0.3.1"}'

Remove-Item -Recurse -Force -ErrorAction Ignore bindmounts
mkdir -Force bindmounts

Remove-Item -Recurse -Force -ErrorAction Ignore state
mkdir -Force state

Write-Host "bringing up network"
echo '{"pid": 1234}' | garden-external-networker -action=up -handle=XXX -configFile=".\ci\local-gdn-ext-net-config\config.json"
if ($LastExitCode -ne 0) {
    throw "garden-external-networker up returned error code: $LastExitCode"
}

Write-Host "bringing down network"
garden-external-networker -action=down -handle=XXX -configFile=".\ci\local-gdn-ext-net-config\config.json"
if ($LastExitCode -ne 0) {
    throw "garden-external-networker down returned error code: $LastExitCode"
}
