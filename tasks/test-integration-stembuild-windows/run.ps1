$ErrorActionPreference = "Stop";
trap { Exit 1 }

Import-Module ./ci/common-scripts/setup-windows-container.psm1
Set-TmpDir

$ROOT_DIR=Get-Location
Write-Host "ROOT: $ROOT_DIR"

$GO_DIR=Join-Path $ROOT_DIR go-work
$STEMBUILD_DIR="$GO_DIR/src/github.com/cloudfoundry-incubator/stembuild"

$request = [System.Net.HttpWebRequest]::Create("https://$env:VCENTER_BASE_URL")
try { $request.GetResponse().Dispose() } catch {}

$ca_cert=new-object System.Text.StringBuilder
$ca_cert.AppendLine("-----BEGIN CERTIFICATE-----")
$ca_cert.AppendLine([System.Convert]::ToBase64String($request.ServicePoint.Certificate.GetRawCertData(), 1))
$ca_cert.AppendLine("-----END CERTIFICATE-----")
$env:VCENTER_CA_CERT=$ca_cert.ToString()

$base_url=$request.ServicePoint.Certificate.Subject.Split("=").Get(2)

# We use an additional dns redirect that will cause TLS to fail
# So we fetch the hostname we're supposed to be using from the Cert
$env:VCENTER_ADMIN_CREDENTIAL_URL=$env:VCENTER_ADMIN_CREDENTIAL_URL.replace($env:VCENTER_BASE_URL, $base_url)
$env:VCENTER_BASE_URL=$base_url

$env:VM_NAME= cat $ROOT_DIR/integration-vm-name/name
$env:BOSH_PSMODULES_REPO="$ROOT_DIR/bosh-psmodules-repo"
$env:GOPATH = $GO_DIR
Write-Host "GOPATH: $env:GOPATH"

New-Item $GO_DIR -ItemType Directory

$TMP_DIR=Join-Path $ROOT_DIR tmp

Write-Host *** creating and setting temp environment variable to $TMP_DIR***
New-Item $TMP_DIR -ItemType Directory

$env:TMP=$TMP_DIR
$env:TEMP=$TMP_DIR

Write-Host ***Cloning stembuild***
Copy-Item stembuild $STEMBUILD_DIR -Recurse -Force

Write-Host ***Building ginkgo***
go get github.com/onsi/ginkgo/ginkgo

$env:TARGET_VM_IP = cat $ROOT_DIR/nimbus-ips/name
$env:STEMBUILD_VERSION = cat $ROOT_DIR/version/version

$env:PATH="$env:GOPATH\bin;$env:PATH"
Set-Location $STEMBUILD_DIR

Write-Host ***Runninng integration tests***
make integration
if ($lastexitcode -ne 0)
{
    throw "integration specs failed"
}
