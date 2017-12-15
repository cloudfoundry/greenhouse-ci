$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

function get-firewall {
	param([string] $profile)
	$firewall = (Get-NetFirewallProfile -Name $profile)
	$result = "{0},{1},{2}" -f $profile,$firewall.DefaultInboundAction,$firewall.DefaultOutboundAction
	return $result
}

function check-firewall {
	param([string] $profile)
	$firewall = (get-firewall $profile)
	Write-Host $firewall
	if ($firewall -ne "$profile,Block,Block") {
		Write-Host $firewall
		Write-Error "Unable to set $profile Profile"
	}
}

function setup-firewall {
  $anyFirewallsDisabled = !!(Get-NetFirewallProfile -All | Where-Object { $_.Enabled -eq "False" })
  $adminRuleMissing = !(Get-NetFirewallRule -Name CFAllowAdmins -ErrorAction Ignore)
  if ($anyFirewallsDisabled -or $adminRuleMissing) {
    $admins = New-Object System.Security.Principal.NTAccount("Administrators")
    $adminsSid = $admins.Translate([System.Security.Principal.SecurityIdentifier])

    $LocalUser = "D:(A;;CC;;;$adminsSid)"
    $otherAdmins = Get-WmiObject win32_groupuser |
    Where-Object { $_.GroupComponent -match 'administrators' } |
    ForEach-Object { [wmi]$_.PartComponent }

    foreach($admin in $otherAdmins)
    {
      $ntAccount = New-Object System.Security.Principal.NTAccount($admin.Name)
      $sid = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
      $LocalUser = $LocalUser + "(A;;CC;;;$sid)"
    }
    New-NetFirewallRule -Name CFAllowAdmins -DisplayName "Allow admins" `
      -Description "Allow admin users" -RemotePort Any `
      -LocalPort Any -LocalAddress Any -RemoteAddress Any `
      -Enabled True -Profile Any -Action Allow -Direction Outbound `
      -LocalUser $LocalUser

    Set-NetFirewallProfile -All -DefaultInboundAction Block -DefaultOutboundAction Block -Enabled True
    check-firewall "public"
    check-firewall "private"
    check-firewall "domain"
    $anyFirewallsDisabled = !!(Get-NetFirewallProfile -All | Where-Object { $_.Enabled -eq "False" })
    $adminRuleMissing = !(Get-NetFirewallRule -Name CFAllowAdmins -ErrorAction Ignore)
    if ($anyFirewallsDisabled -or $adminRuleMissing) {
      Write-Host "anyFirewallsDisabled: $anyFirewallsDisabled"
      Write-Host "adminRuleMissing: $adminRuleMissing"
      Write-Error "Failed to Set Firewall rule"
    }
  }
}

setup-firewall

go.exe version

$env:GOPATH = $PWD
push-location src/code.cloudfoundry.org/windows2016fs
  $image_tag = $env:TEST_CONTAINER_IMAGE_TAG
  if ($image_tag -eq $null -or $image_tag -eq "") {
      $image_tag = (cat IMAGE_TAG)
  }
  $output_dir = "temp/windows2016fs"
  mkdir -Force $output_dir
  go run ./cmd/hydrate/main.go -image "cloudfoundry/windows2016fs" -outputDir $output_dir -tag $image_tag
  if ($LastExitCode -ne 0) {
      throw "Download image process returned error code: $LastExitCode"
  }

  go build -o extract.exe ./cmd/extract
  if ($LastExitCode -ne 0) {
      throw "Build extract process returned error code: $LastExitCode"
  }
  $rootfsTgz = (get-item "$output_dir\windows2016fs-*.tgz").FullName
  $env:WINC_TEST_ROOTFS = (.\extract.exe $rootfsTgz "c:\ProgramData\windows2016fs\layers")
  if ($LastExitCode -ne 0) {
      throw "Extract process returned error code: $LastExitCode"
  }
pop-location

$env:GOPATH = $PWD
$env:PATH="$env:GOPATH\bin;" +$env:PATH

$config = '{"name": "winc-nat"}'
set-content -path "$env:TEMP\interface.json" -value $config
go run src/code.cloudfoundry.org/winc/cmd/winc-network/main.go --action delete --configFile "$env:TEMP/interface.json"

cd $env:GOPATH/src/code.cloudfoundry.org/winc

Write-Host "Installing Ginkgo"
go.exe install ./vendor/github.com/onsi/ginkgo/ginkgo
if ($LastExitCode -ne 0) {
    throw "Ginkgo installation process returned error code: $LastExitCode"
}

ginkgo.exe -p -r -race -keepGoing -randomizeSuites -failOnPending -slowSpecThreshold 10
$exitCode = $LastExitCode

Exit $exitCode
