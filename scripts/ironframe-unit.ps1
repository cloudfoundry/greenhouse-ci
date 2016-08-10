# Install Visual Studio
ci\scripts\vs-install.ps1

fsutil quota enforce C:
net start seclogon

cd ironframe
.\build.bat test
if ($LastExitCode -ne 0)
{
    Write-Error $_
    exit 1
}
