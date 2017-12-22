$ErrorActionPreference = "Stop";
trap { $host.SetShouldExit(1) }

function Kill-Garden {
  Get-Process | foreach { if ($_.name -eq "gdn") { kill -Force $_.Id } }
}


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

$env:PATH = "C:/var/vcap/bosh/bin;" + $env:PATH

go version

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
    $wincTestRootfs = (.\extract.exe $rootfsTgz "c:\ProgramData\windows2016fs\layers")
    if ($LastExitCode -ne 0) {
        throw "Extract process returned error code: $LastExitCode"
    }
pop-location

$env:GOPATH = "$PWD/garden-runc-release"
$env:PATH= "$env:GOPATH/bin;" + $env:PATH

$wincPath = "$PWD/winc-binary/winc.exe"
$wincNetworkPath = "$PWD/winc-network-binary/winc-network.exe"

$config = '{"mtu": 0, "network_name": "winc-nat", "subnet_range": "172.30.0.0/22", "gateway_address": "172.30.0.1"}'
set-content -path "$env:TEMP/interface.json" -value $config

& $wincNetworkPath --action create --configFile "$env:TEMP/interface.json"

$wincImagePath = "$PWD/winc-image-binary/winc-image.exe"
$nstarPath = "$PWD/nstar-binary/nstar.exe"

push-location garden-runc-release
  go install ./src/github.com/onsi/ginkgo/ginkgo
  if ($LastExitCode -ne 0) {
      throw "Ginkgo installation process returned error code: $LastExitCode"
  }

  go build -o gdn.exe ./src/code.cloudfoundry.org/guardian/cmd/gdn
  if ($LastExitCode -ne 0) {
      throw "Building gdn.exe process returned error code: $LastExitCode"
  }

  # Kill any existing garden servers
  Kill-Garden

  $depotDir = "$env:TEMP\depot"
  Remove-Item -Recurse -Force -ErrorAction Ignore $depotDir
  mkdir $depotDir -Force

  $env:GARDEN_ADDRESS = "127.0.0.1"
  $env:GARDEN_PORT = "8888"

  $tarBin = (get-command tar.exe).source

  $imageRoot="C:\var\vcap\packages\winc-image\rootfs"

  Start-Process `
    -NoNewWindow `
    -RedirectStandardOutput gdn.out.log `
    -RedirectStandardError gdn.err.log `
    .\gdn.exe -ArgumentList `
    "server `
    --skip-setup `
    --runtime-plugin=$wincPath `
    --runtime-plugin-extra-arg=--image-store=$imageRoot `
    --image-plugin=$wincImagePath `
    --image-plugin-extra-arg=--store=$imageRoot `
    --image-plugin-extra-arg=--log=winc-image.log `
    --image-plugin-extra-arg=--debug `
    --network-plugin=$wincNetworkPath `
    --network-plugin-extra-arg=--configFile=$env:TEMP/interface.json `
    --network-plugin-extra-arg=--log=winc-network.log `
    --network-plugin-extra-arg=--debug `
    --bind-ip=$env:GARDEN_ADDRESS `
    --bind-port=$env:GARDEN_PORT `
    --default-rootfs=$wincTestRootfs `
    --nstar-bin=$nstarPath `
    --tar-bin=$tarBin `
    --depot $depotDir `
    --log-level=debug"

  # wait for server to start up
  # and then curl to confirm that it is
  Start-Sleep -s 5
  $pingResult = (curl -UseBasicParsing "http://${env:GARDEN_ADDRESS}:${env:GARDEN_PORT}/ping").StatusCode
  if ($pingResult -ne 200) {
      throw "Pinging garden server failed with code: $pingResult"
  }

  $env:GARDEN_TEST_ROOTFS="$wincTestRootfs"
  Push-Location src/code.cloudfoundry.org/garden-integration-tests
    ginkgo -p -randomizeSuites -noisyPendings=false
  Pop-Location
Pop-Location
$ExitCode="$LastExitCode"

Kill-Garden
& $wincNetworkPath --action delete --configFile "$env:TEMP/interface.json"

if ($ExitCode -ne 0) {
  echo "`n`n`n############# gdn.exe STDOUT"
  Get-Content garden-runc-release/gdn.out.log
  echo "`n`n`n############# gdn.exe STDERR"
  Get-Content garden-runc-release/gdn.err.log
  echo "`n`n`n############# winc-image.exe"
  Get-Content garden-runc-release/winc-image.log
  echo "`n`n`n############# winc-network.exe"
  Get-Content garden-runc-release/winc-network.log
  Exit $ExitCode
}
