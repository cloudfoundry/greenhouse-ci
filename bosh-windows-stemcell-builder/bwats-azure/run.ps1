$ErrorActionPreference = "Stop"
# DO NOT USE THE trap { exit 1 } pattern as it swallows errors

# Validate Environment and Locate Resource Files

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
    }
}

# TODO: Get pigz and go from pipeline (tar.exe is required by Concourse so not worth it).
$RequiredExes=@(
    'go.exe',
    'pigz.exe',
    'tar.exe'
)
foreach ($exe in $RequiredExes) {
    Get-Command -CommandType Application -Name $exe > $null
}

$VersionFile=(Resolve-Path "${PWD}\azure-stemcell-version\version*").Path
if (($VersionFile | Measure-Object).Count -ne 1) {
    if (($VersionFile | Measure-Object).Count -eq 0) {
        Write-Error "No files in 'azure-stemcell-version' directory: ${VersionFile}"
    } else {
        Write-Error "Too many files in 'azure-stemcell-version' directory: ${VersionFile}"
    }
    Exit 1
}

$VhdFile=(Resolve-Path "${PWD}\azure-base-vhd-uri\*vhd-uri.txt").Path
if (($VhdFile | Measure-Object).Count -ne 1) {
    if (($VhdFile | Measure-Object).Count -eq 0) {
        Write-Error "No files in 'azure-base-vhd-uri' directory: ${VhdFile}"
    } else {
        Write-Error "Too many files in 'azure-base-vhd-uri' directory: ${VhdFile}"
    }
    Exit 1
}

$DestDir=Join-Path $env:WORKING_DIR "stemcell-out-$(Get-Date -f yyyyMMddhhmmFF)"
New-Item -ItemType Directory -Path $DestDir

$TempDir=Join-Path $env:WORKING_DIR "Temp"
if (-Not (Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir
}

# Build azstemcell

$LocalBin="${PWD}\bin"
New-Item -ItemType directory -Path $LocalBin
$env:Path="$LocalBin;$env:Path"

if (-Not (Test-Path "$PWD\azstemcell")) {
    Write-Error "Missing azstemcell repository"
}

$MainPath=(Get-ChildItem -Recurse -Path "$PWD\azstemcell" | where { $_.Name -eq 'main.go' })
if ($MainPath -eq $null) {
    Write-Error "Failed to find 'main.go' in $PWD\azstemcell"
}
go.exe build -o "$LocalBin\azstemcell.exe" $MainPath.FullName
if ($LASTEXITCODE -ne 0) {
    Write-Error "go: failed to build azstemcell ${LASTEXITCODE}"
}

# Create Stemcell

# Use finally block to ensure we remove the stemcell
try {
    azstemcell.exe `
        -vhdfile $VhdFile `
        -key $env:AZURE_SOURCE_KEY `
        -versionfile $VersionFile `
        -os $env:STEMCELL_OS `
        -dest $DestDir `
        -temp $TempDir

    if ($LASTEXITCODE -ne 0) {
        Write-Error "azcell.exe: non-zero exit code ${LASTEXITCODE}"
    }

    # Setup env vars for BWATs

    $StemcellPath=(Resolve-Path "$DestDir\*.tgz").Path
    if (($StemcellPath | Measure-Object).Count -ne 1) {
        Write-Error "Too many files in stemcell destination directory: ${StemcellPath}"
        Exit 1
    }
    $env:STEMCELL_PATH=$StemcellPath

    $env:IAAS='azure'

    $env:BWATS_BOSH_TIMEOUT='3h' # Massive timeout

    # Run BWATs

    Push-Location "$PWD\stemcell-builder"
        bundle install --without test
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Running command: 'bundle install --without test'"
        }
        rake package:bwats
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Running command: 'rake package:bwats'"
        }
        rake run:bwats['azure']
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Running command: 'rake run:bwats['azure']'"
        }
    Pop-Location

} finally {
    Remove-Item -Recurse -Path $DestDir
}

Exit 0
