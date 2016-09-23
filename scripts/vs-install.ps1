trap {
  write-error $_
  exit 1
}

$env:PATH = $env:Path + ";D:\Programs\VisualStudio\Common7\IDE"

# Install Visual Studio if it doesn't exist
if ((Get-Command "WDExpress.exe" -ErrorAction SilentlyContinue) -eq $null) {
  Write-Host "Installing Visual Studio Express 2013"
  Invoke-WebRequest "https://download.microsoft.com/download/9/6/4/96442E58-C65C-4122-A956-CCA83EECCD03/wdexpress_full.exe" -OutFile "vs-express-setup.exe"

  $p = Start-Process -FilePath "vs-express-setup.exe" -ArgumentList "/silent /passive /norestart /CustomInstallPath D:\Programs\VisualStudio" -Wait -PassThru

  if($p.ExitCode -ne 0) {
    throw "Visual Studio Express 2013 installation process returned error code: $($p.ExitCode)"
  }
  Write-Host "Installed Visual Studio Express 2013"
}

# Update VCTargetsPath Registry Key
$VCTargetsPath = "HKLM:\SOFTWARE\Microsoft\MSBuild\ToolsVersions\12.0\"
$name = "VCTargetsPath"
$value = '$(MSBuildExtensionsPath32)\Microsoft.Cpp\v4.0\V120'
if(!(Test-Path $VCTargetsPath)) {
  New-Item -Path $VCTargetsPath -Force
  New-ItemProperty -Path $VCTargetsPath -Name $name -Value $value -Force
} else {
  New-ItemProperty -Path $VCTargetsPath -Name $name -Value $value -Force
}

Write-Host "Installing .NET Framework 3.5"
Install-WindowsFeature Net-Framework-Core
Write-Host "Installed .NET Framework 3.5"
