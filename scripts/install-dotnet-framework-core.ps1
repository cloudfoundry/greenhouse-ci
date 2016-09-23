$Error.Clear()

Configuration Features {
  Node "localhost" {

    WindowsFeature NetFrameworkCore {
      Ensure = "Present"
        Name = "Net-Framework-Core"
    }
  }
}

Install-WindowsFeature DSC-Service
Features
Start-DscConfiguration -Wait -Path .\Features -Force -Verbose

if ($Error) {
  Write-Host "Error summary:"
  foreach($ErrorMessage in $Error)
  {
    Write-Host $ErrorMessage
  }
  Write-Host "Setup failed. The above errors occurred."
} else {
  Write-Host "Setup completed successfully."
}
