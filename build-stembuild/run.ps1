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

New-Item $LIBRSYNC_BUILD_DIR -ItemType Directory
New-Item $LIBRSYNC_INSTALL_DIR -ItemType Directory

cd $LIBRSYNC_BUILD_DIR

cmake -DCMAKE_INSTALL_PREFIX=$LIBRSYNC_INSTALL_DIR -DCMAKE_BUILD_TYPE=release -G "MinGW Makefiles" ..
mingw32-make

Write-Host ***Cloning stembuild***
cd $ROOT_DIR
go get -d github.com/pivotal-cf-experimental/stembuild

Write-Host ***Copying librsync sources into stembuild***
$STEMBUILD_RDIFF_DIR=Join-Path $STEMBUILD_DIR rdiff
cd $STEMBUILD_RDIFF_DIR

copy $LIBRSYNC_DIR/src/* .
copy $LIBRSYNC_BUILD_DIR/src/* .
del rdiff.c

Write-Host ***Building Stembuild***
cd ..
go install

Write-Host ***Copying stembuild binary to errand log directory***
copy $GO_DIR/bin/stembuild.exe $OUTPUT_DIR/stembuild-$VERSION.exe
