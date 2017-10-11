$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

# get tar on the path
$env:PATH="$env:PATH;C:\var\vcap\bosh\bin"

$pre_version=(cat version/version)

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
    echo $pre_version > VERSION
    git config --global user.email "pivotal-netgarden-eng@pivotal.io"
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
    git config --global user.name "Greenhouse CI"
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
    git add VERSION
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
    git commit -m "WIP - test"
    if ($LastExitCode -ne 0) {
      exit $LastExitCode
    }
  }

  ./scripts/create-release.ps1
  if ($LastExitCode -ne 0) {
    exit $LastExitCode
  }
pop-location

if ($env:DEV_ENV -ne $null -and $env:DEV_ENV -ne "") {
  cp windows2016fs-release/bin/create.exe "create-binary-windows/create-$pre_version-windows-amd64.exe"
}
