$ErrorActionPreference = "Stop";
trap { Exit 1 }

Import-Module ./ci/common-scripts/setup-windows-container.psm1
Set-TmpDir

$ROOT_DIR=Get-Location
Write-Host "ROOT: $ROOT_DIR"

$GO_DIR=Join-Path $ROOT_DIR go-work
$STEMBUILD_DIR="$GO_DIR/src/github.com/cloudfoundry-incubator/stembuild"


$env:VM_NAME_PREFIX="construct-windows-integration-ci-${env:OS_LINE}"
$env:GOPATH = $GO_DIR
Write-Host "GOPATH: $env:GOPATH"

New-Item $GO_DIR -ItemType Directory

$TMP_DIR=Join-Path $ROOT_DIR tmp

Write-Host *** creating and setting temp environment variable to $TMP_DIR***
New-Item $TMP_DIR -ItemType Directory

$env:TMP=$TMP_DIR
$env:TEMP=$TMP_DIR

Write-Host ***Cloning stembuild***
Copy-Item stembuild $STEMBUILD_DIR -Recurse -Force

Write-Host ***Building ginkgo***
go get github.com/onsi/ginkgo/ginkgo

$env:USER_PROVIDED_IP = cat $ROOT_DIR/vcenter-ips/name
$env:STEMBUILD_VERSION = cat $ROOT_DIR/version/version

$env:PATH="$env:GOPATH\bin;$env:PATH"
Set-Location $STEMBUILD_DIR

Write-Host ***Runninng integration tests***
make integration
if ($lastexitcode -ne 0)
{
    throw "integration specs failed"
}
