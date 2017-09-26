$ErrorActionPreference = "Stop"

# Test these early so that we don't waste time making the stemcell
# ignoring: VM_EXTENSIONS
#
$RequiredEnvVars=@(
    'BOSH_CA_CERT',
    'BOSH_CLIENT',
    'BOSH_CLIENT_SECRET',
    'BOSH_TARGET',
    'STEMCELL_OS',
    'AZ',
    'VM_TYPE',
    'NETWORK',
    'WORKING_DIR',
    'AZURE_SOURCE_KEY'
)
foreach ($key in $RequiredEnvVars) {
    if ((Get-Item env:$key).Value -eq $null) {
        Write-Error "Missing required env variable: $key"
        Exit 1
    }
}

$VersionFile=(Resolve-Path .\azure-stemcell-version\*.txt).Path
if (($VersionFile | Measure-Object).Count -ne 1) {
    Write-Error "Too many files in 'azure-stemcell-version' directory: ${VersionFile}"
    Exit 1
}

$VhdFile=(Resolve-Path .\azure-base-vhd-uri\*.txt).Path
if (($VhdFile | Measure-Object).Count -ne 1) {
    Write-Error "Too many files in 'azure-base-vhd-uri' directory: ${VhdFile}"
    Exit 1
}

$DestDir=Join-Path $env:WORKING_DIR "stemcell-out-$(Get-Date -f yyyyMMddhhmmFF)"
New-Item -ItemType Directory -Path $DestDir

$TempDir=Join-Path $env:WORKING_DIR "Temp"
if (-Not (Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir
}

azcell.exe `
    -vhdfile $VhdFile `
    -key $env:AZURE_SOURCE_KEY `
    -versionfile $VersionFile `
    -os $env:STEMCELL_OS `
    -dest $DestDir `
    -temp $TempDir

if ($LASTEXITCODE -ne 0) {
    Write-Error "azcell.exe: non-zero exit code ${LASTEXITCODE}"
    Exit $LASTEXITCODE
}

# Setup env vars for BWATs

$StemcellPath=(Resolve-Path "$DestDir\*.tgz").Path
if (($StemcellPath | Measure-Object).Count -ne 1) {
    Write-Error "Too many files in stemcell destination directory: ${StemcellPath}"
    Exit 1
}
$env:STEMCELL_PATH=$StemcellPath

$env:IAAS='azure'

# Run BWATs

Push-Location "$PWD\stemcell-builder"
    bundle install --without test
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Running command: 'bundle install --without test'"
        Exit 1
    }
    rake package:bwats
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Running command: 'rake package:bwats'"
        Exit 1
    }
    rake run:bwats['azure']
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Running command: 'rake run:bwats['azure']'"
        Exit 1
    }
Pop-Location

# TODO: Remove stemcell on error
Remove-Item -Recurse -Path $DestDir

Exit 0
