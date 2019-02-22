$ErrorActionPreference = "Stop";
trap { Exit 1 }

$ROOT_DIR= (Get-Item "$PSScriptRoot/../../../../..").FullName

$GO_DIR=Join-Path $ROOT_DIR go-work
$STEMBUILD_DIR="$GO_DIR/src/github.com/cloudfoundry-incubator/stembuild"

$env:GOPATH = $GO_DIR
Write-Host "GOPATH: $env:GOPATH"

New-Item $GO_DIR -ItemType Directory

Write-Host ***Cloning stembuild***
cd $ROOT_DIR
Copy-Item stembuild $STEMBUILD_DIR -Recurse -Force

Write-Host ***Test Stembuild Code***

Write-Host ***Building ginkgo***
go get github.com/onsi/ginkgo/ginkgo
go install github.com/onsi/ginkgo/ginkgo

$env:PATH="${GO_DIR}/bin;$env:PATH"

cd $STEMBUILD_DIR

# run tests
ginkgo -r -v -randomizeAllSpecs -randomizeSuites iaas_cli
if ($lastexitcode -ne 0)
{
  throw "contract tests failed"
}
