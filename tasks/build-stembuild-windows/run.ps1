$ErrorActionPreference = "Stop";
trap { Exit 1 }

$ROOT_DIR= (Get-Item "$PSScriptRoot/../../..").FullName
$OUTPUT_DIR=Join-Path $ROOT_DIR output
$VERSION=Get-Content (Join-Path (Join-Path $ROOT_DIR stembuild-version) version)

$GO_DIR=Join-Path $ROOT_DIR go-work
$STEMBUILD_DIR="$GO_DIR/src/github.com/cloudfoundry-incubator/stembuild"

$env:GOPATH = $GO_DIR
Write-Host "GOPATH: $env:GOPATH"

New-Item $GO_DIR -ItemType Directory

Write-Host ***Cloning stembuild***
cd $ROOT_DIR
Copy-Item stembuild $STEMBUILD_DIR -Recurse -Force

Write-Host ***Building Stembuild***
cd $STEMBUILD_DIR
go generate
go install
go build -o out/stembuild.exe
$env:PATH="${GO_DIR}/bin;$env:PATH"

Write-Host ***Copying stembuild to output directory***
copy $GO_DIR/bin/stembuild.exe $OUTPUT_DIR/stembuild-windows-x86_64-$VERSION.exe
