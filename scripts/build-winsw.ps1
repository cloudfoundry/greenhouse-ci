# Add MSBuild to Path
$env:PATH = $env:Path + "C:\Windows\Microsoft.Net\Framework\v4.0.30319"

# Install Net-Framework-Core - required for building winsw
PowerShell -File 'ci\scripts\install-dotnet-framework-core.ps1'

cd winsw
MSBuild ./winsw.csproj

if ($LastExitCode -ne 0)
{
    Write-Error $_
    exit 1
}

$version = $(cat ../version/number)
Copy-Item ./bin/Debug/winsw.exe ../winsw-output/winsw-$version.exe
