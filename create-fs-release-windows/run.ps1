$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

# get tar on the path
$env:PATH="$env:PATH;C:\var\vcap\bosh\bin"

$timestamp=(cat create-timestamp/create-*-timestamp)
$sha=(cat sha/create-*-windows-amd64.exe.sha256)

push-location windows2016fs-release
  git config core.filemode false
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
  git submodule foreach --recursive git config core.filemode false
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }

  if ($env:DEV_ENV -eq $null -or $env:DEV_ENV -eq "") {
    set-content -path VERSION -value $timestamp -NoNewLine
    set-content -path CREATE_BIN_SHA_WINDOWS -value $sha

    git config --global user.email "pivotal-netgarden-eng@pivotal.io"
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
    git config --global user.name "Greenhouse CI"
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
    git add VERSION CREATE_BIN_SHA_WINDOWS
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
    git commit -m "WIP - test"
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
  }

  new-item -type directory -force .\new-dir
  ./scripts/create-release.ps1 -tarball ./new-dir/release.tgz
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
pop-location
