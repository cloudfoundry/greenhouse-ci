$ErrorActionPreference = "Stop";
trap { Exit 1 }

$ROOT_DIR= (Get-Item "$PSScriptRoot/../../..").FullName
$OUTPUT_DIR=Join-Path $ROOT_DIR output

$GO_DIR=Join-Path $ROOT_DIR go-work
$STEMBUILD_DIR="$GO_DIR/src/github.com/cloudfoundry-incubator/stembuild"

$env:GOPATH = $GO_DIR
Write-Host "GOPATH: $env:GOPATH"

New-Item $GO_DIR -ItemType Directory

Write-Host ***Cloning stembuild***
cd $ROOT_DIR
Copy-Item stembuild $STEMBUILD_DIR -Recurse -Force

Write-Host ***Building ginkgo***
go get github.com/onsi/ginkgo/ginkgo
go get -u github.com/vmware/govmomi/govc

$env:USER_PROVIDED_IP = cat $ROOT_DIR/../vcenter-ips/*

$env:PATH="$env:GOPATH\bin;$env:PATH"
cd $STEMBUILD_DIR

# run tests
Write-Host ***Runninng integration tests***

ginkgo -r -randomizeAllSpecs integration/construct
if ($lastexitcode -ne 0)
{
    throw "integration specs failed"
}
