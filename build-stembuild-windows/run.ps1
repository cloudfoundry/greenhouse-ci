$ErrorActionPreference = "Stop";
trap { Exit 1 }

$ROOT_DIR= (Get-Item "$PSScriptRoot/../..").FullName
$LIBRSYNC_DIR=Join-Path $ROOT_DIR librsync
$OUTPUT_DIR=Join-Path $ROOT_DIR output
$VERSION=Get-Content (Join-Path (Join-Path $ROOT_DIR stembuild-version) version)

$GO_DIR=Join-Path $ROOT_DIR go-work
$STEMBUILD_DIR="$GO_DIR/src/github.com/pivotal-cf-experimental/stembuild"

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
$new_env_path = ($env:Path.Split(';') | Where-Object {$_ -notlike "*git"}) -join ';'
$env:Path = $new_env_path

cmake -DCMAKE_INSTALL_PREFIX=$LIBRSYNC_INSTALL_DIR -DCMAKE_BUILD_TYPE=release -G "MinGW Makefiles" ..
mingw32-make
mingw32-make.exe test

#Restore environment variable back
$env:Path = $orig_env_path

Write-Host ***Cloning stembuild***
cd $ROOT_DIR
Copy-Item stembuild $STEMBUILD_DIR -Recurse -Force

Write-Host ***Copying librsync sources into stembuild***
$STEMBUILD_RDIFF_DIR=Join-Path $STEMBUILD_DIR rdiff
cd $STEMBUILD_RDIFF_DIR

copy $LIBRSYNC_DIR/src/* .
copy $LIBRSYNC_BUILD_DIR/src/* .
copy $LIBRSYNC_BLAKE2_DIR/* .
del rdiff.c

Write-Host ***Test Stembuild Code***
cd ..
go test


Write-Host ***Building Stembuild***
go install

Write-Host ***Copying stembuild to output directory***
copy $GO_DIR/bin/stembuild.exe $OUTPUT_DIR/stembuild-windows-x86_64-$VERSION.exe
