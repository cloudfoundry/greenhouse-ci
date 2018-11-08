$ErrorActionPreference = "Stop";
trap { Exit 1 }

$ROOT_DIR= (Get-Item "$PSScriptRoot/../../..").FullName
$OUTPUT_DIR=Join-Path $ROOT_DIR output
$VERSION=Get-Content (Join-Path (Join-Path $ROOT_DIR stembuild-version) version)

$GO_DIR=Join-Path $ROOT_DIR go-work
$STEMBUILD_DIR="$GO_DIR/src/github.com/pivotal-cf-experimental/stembuild"

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

Write-Host ***Building Stembuild***
cd $STEMBUILD_DIR
go install
go build -o out/stembuild
$env:PATH="${GO_DIR}/bin;$env:PATH"

# run tests
ginkgo -r -randomizeAllSpecs integration
if ($lastexitcode -ne 0)
{
  throw "integration specs failed"
}
ginkgo -r -randomizeAllSpecs -randomizeSuites -skipPackage integration
if ($lastexitcode -ne 0)
{
  throw "unit tests failed"
}

Write-Host ***Copying stembuild to output directory***
copy $GO_DIR/bin/stembuild.exe $OUTPUT_DIR/stembuild-windows-x86_64-$VERSION.exe
