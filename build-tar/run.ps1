$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

# remove sh.exe from $env:PATH
$env:PATH = ($env:PATH.Split(';') | Where-Object { $_ -ne 'c:\var\vcap\packages\git\bin' }) -join ';'

bsdtar/install.ps1
Exit $LastExitCode
