$Error.Clear()

Configuration CFWindows {
  Node "localhost" {

    WindowsFeature IISWebServer {
      Ensure = "Present"
        Name = "Web-Webserver"
    }
  }
}

Install-WindowsFeature DSC-Service
CFWindows
Start-DscConfiguration -Wait -Path .\CFWindows -Force -Verbose

if ($Error) {
  Write-Host "Error summary:"
  foreach($ErrorMessage in $Error)
  {
    Write-Host $ErrorMessage
  }
  Write-Host -Prompt "Setup failed. The above errors occurred. Press Enter to exit"
} else {
  Write-Host -Prompt "Setup completed successfully. Press Enter to exit"
}
