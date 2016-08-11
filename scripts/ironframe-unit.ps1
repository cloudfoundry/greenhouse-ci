# Install Visual Studio
PowerShell -File 'ci\scripts\vs-install.ps1'

# Install IISWebServer - required for tests
# PowerShell -File 'ci\scripts\install-iiswebserver.ps1'

fsutil quota enforce C:
net start seclogon

cd ironframe
.\build.bat test
if ($LastExitCode -ne 0)
{
    Write-Error $_
    exit 1
}
