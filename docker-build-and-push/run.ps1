$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

function Run-Docker {
  param([String[]] $cmd)

  docker @cmd
  if ($LASTEXITCODE -ne 0) {
    Exit $LASTEXITCODE
  }
}

restart-service docker

$version=(cat version/number)

mkdir buildDir
cp $env:DOCKERFILE buildDir\Dockerfile
cp git-setup\Git-*-64-bit.exe buildDir\
cp tar\tar-*.exe buildDir\
curl -UseBasicParsing -Outfile buildDir\rewrite.msi -Uri "https://download.microsoft.com/download/C/9/E/C9E8180D-4E51-40A6-A9BF-776990D8BCA9/rewrite_amd64.msi"
cd buildDir

Run-Docker "--version"
Run-Docker "build", "-t", "$env:IMAGE_NAME", "-t", "${env:IMAGE_NAME}:$version", "."
Run-Docker "images", "-a"
Run-Docker "login", "-u", "$env:DOCKER_USERNAME", "-p", "$env:DOCKER_PASSWORD"
Run-Docker "push", "${env:IMAGE_NAME}:latest"
Run-Docker "push", "${env:IMAGE_NAME}:$version"
