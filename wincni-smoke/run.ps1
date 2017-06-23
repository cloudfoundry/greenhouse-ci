$ErrorActionPreference = "Stop";
trap {
  winc delete smoke-test
  $host.SetShouldExit(1)
}

$env:GOPATH = "$PWD\cf-networking-release"
$wincPath = "$PWD\winc-binary"
$env:PATH = $env:GOPATH + "/bin;C:/go/bin;C:/Program Files/Docker;C:/var/vcap/bosh/bin;$wincPath;" + $env:PATH

go version
$wincTestRootfs = (docker inspect microsoft/windowsservercore | ConvertFrom-Json).GraphDriver.Data.Dir | ConvertTo-Json

mkdir -Force smoke-test
$config = @"
{
  "ociVersion":"1.0.0-rc5-dev",
  "platform":{"os":"windows","arch":"amd64"},
  "process":{
    "user":{"uid":0,"gid":0},
    "args":["powershell"],
    "cwd":"/"
    },
  "root":{"path":$wincTestRootfs}
}
"@
Set-Content "smoke-test/config.json" $config


Write-Host "Installing garden-external-networker"
go install garden-external-networker
if ($LastExitCode -ne 0) {
    throw "garden-external-networker installation process returned error code: $LastExitCode"
}

Write-Host "creating directories"
Remove-Item -Recurse -Force -ErrorAction Ignore cni-config
mkdir -Force cni-config
add-content ".\cni-config\\wincni.conf" '{"type": "wincni", "cniVersion": "0.3.1"}'

Remove-Item -Recurse -Force -ErrorAction Ignore bindmounts
mkdir -Force bindmounts

Remove-Item -Recurse -Force -ErrorAction Ignore state
mkdir -Force state

Write-Host "creating container"
winc create -b "$PWD\smoke-test" smoke-test
if ($LastExitCode -ne 0) {
    throw "failed to create container"
}

Write-Host "getting free port"
$Listener = [System.Net.Sockets.TcpListener]0
$Listener.Start()
$hostPort = $Listener.LocalEndpoint.Port
$Listener.Stop()

Write-Host "mapping ports"
$networkStdin = @"
{
  "pid": 1234,
  "netin": [{
      "host_port": $hostPort,
      "container_port": 9999
    }]
}
"@
echo $networkStdin  | garden-external-networker -action=up -handle=smoke-test -configFile=".\ci\local-gdn-ext-net-config\config.json"
if ($LastExitCode -ne 0) {
    throw "garden-external-networker up returned error code: $LastExitCode"
}


$serverProcess = @'
  $Listener = [System.Net.Sockets.TcpListener]9999
  $Listener.Start()
  $Listener.AcceptTcpClient().Close()
'@

Write-Host "exec server process"
winc exec --detach smoke-test powershell.exe $serverProcess
if ($LastExitCode -ne 0) {
    throw "failed to exec server process"
}

Write-Host "pinging host port"
(new-object Net.Sockets.TcpClient).Connect("127.0.0.1", $hostPort)

Write-Host "bringing down network"
garden-external-networker -action=down -handle=smoke-test -configFile=".\ci\local-gdn-ext-net-config\config.json"
if ($LastExitCode -ne 0) {
    throw "garden-external-networker down returned error code: $LastExitCode"
}

Write-Host "deleting container"
winc delete smoke-test
if ($LastExitCode -ne 0) {
    throw "failed to delete container"
}
