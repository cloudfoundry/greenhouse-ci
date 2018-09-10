$ErrorActionPreference = "Stop";
trap { Exit 1 }

$ROOT_DIR= (Get-Item "$PSScriptRoot/../../..").FullName
$LIBRSYNC_DIR=Join-Path $ROOT_DIR librsync
$OUTPUT_DIR=Join-Path $ROOT_DIR output
$VERSION=Get-Content (Join-Path (Join-Path $ROOT_DIR stempatch-version) version)

$GO_DIR=Join-Path $ROOT_DIR go-work
$STEMPATCH_DIR="$GO_DIR/src/github.com/pivotal-cf/stempatch"

$env:GOPATH = $GO_DIR
Write-Host "GOPATH: $env:GOPATH"

New-Item $GO_DIR -ItemType Directory

Write-Host ***Generating librsync sources***
$LIBRSYNC_BUILD_DIR= Join-Path $LIBRSYNC_DIR build
$LIBRSYNC_INSTALL_DIR= Join-Path $LIBRSYNC_DIR install
$LIBRSYNC_BLAKE2_DIR= Join-Path (Join-Path $LIBRSYNC_DIR src) blake2

New-Item $LIBRSYNC_BUILD_DIR -ItemType Directory
New-Item $LIBRSYNC_INSTALL_DIR -ItemType Directory

cd $LIBRSYNC_BUILD_DIR

#Remove Git from path as CMake does not like sh in the path
$orig_env_path = $env:Path

Write-Host "Removing Git directory from path"
$new_env_path = ($env:Path.Split(';') | Where-Object {$_ -notlike "*git*"}) -join ';'
Write-Host "Updating path to: $new_env_path"
$env:Path = $new_env_path

cmake -DCMAKE_INSTALL_PREFIX=$LIBRSYNC_INSTALL_DIR -DCMAKE_BUILD_TYPE=release -G "MinGW Makefiles" ..
mingw32-make
mingw32-make.exe test

#Restore environment variable back
Write-Host "Reverting Path to original value"
$env:Path = $orig_env_path
Write-Host "Reverted Path: $env:Path"

Write-Host ***Cloning stempatch***
cd $ROOT_DIR
Copy-Item stempatch $STEMPATCH_DIR -Recurse -Force

Write-Host ***Copying librsync sources into stempatch***
$STEMPATCH_RDIFF_DIR=Join-Path $STEMPATCH_DIR rdiff
cd $STEMPATCH_RDIFF_DIR

copy $LIBRSYNC_DIR/src/* .
copy $LIBRSYNC_BUILD_DIR/src/* .
copy $LIBRSYNC_BLAKE2_DIR/* .
del rdiff.c

Write-Host ***Test Stempatch Code***
cd ..

Write-Host ***Building ginkgo***
go get github.com/onsi/ginkgo/ginkgo
go install github.com/onsi/ginkgo/ginkgo

Write-Host ***Building Stempatch***
go install
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

Write-Host ***Copying stempatch to output directory***
copy $GO_DIR/bin/stempatch.exe $OUTPUT_DIR/stempatch-windows-x86_64-$VERSION.exe
