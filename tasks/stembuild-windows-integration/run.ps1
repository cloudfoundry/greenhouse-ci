$ErrorActionPreference = "Stop";
trap { Exit 1 }

$ROOT_DIR= (Get-Item "$PSScriptRoot/../../..").FullName
$OUTPUT_DIR=Join-Path $ROOT_DIR output
$VERSION=Get-Content (Join-Path (Join-Path $ROOT_DIR stembuild-version) version)

$JSON_TEMPLATE="{\`"DiskProvisioning\`": \`"thin\`",\`"MarkAsTemplate\`": false,\`"Name\`": \`"stembuild_linux\`",\`"IPAllocationPolicy\`": \`"fixedPolicy\`",\`"IPProtocol\`": \`"IPv4\`",\`"NetworkMapping\`": [{\`"Name\`": \`"custom\`",\`"Network\`": \`"$ENV:GOVC_NETWORK\`"}],\`"PropertyMapping\`": [{\`"Key\`": \`"ip0\`",\`"Value\`": \`"$ENV:EXISTING_VM_IP\`"},{\`"Key\`": \`"cidr\`",\`"Value\`": \`"25\`"},{\`"Key\`": \`"gateway\`",\`"Value\`": \`"10.74.35.1\`"},{\`"Key\`": \`"DNS\`",\`"Value\`": \`"8.8.8.8\`"}],\`"PowerOn\`": true,\`"InjectOvfEnv\`": false,\`"WaitForIP\`": false}"

$GO_DIR=Join-Path $ROOT_DIR go-work
$STEMBUILD_DIR="$GO_DIR/src/github.com/cloudfoundry-incubator/stembuild"

$env:GOPATH = $GO_DIR
Write-Host "GOPATH: $env:GOPATH"

New-Item $GO_DIR -ItemType Directory

$AWS_ACCESS_KEY_ID=$ENV:AWS_ACCESS_KEY
$AWS_SECRET_ACCESS_KEY=$ENV:AWS_SECRET_KEY

& "C:\Program Files\Amazon\AWSCLI\bin\aws.cmd" s3 cp "s3://$ENV:ROOT_BUCKET/ova-for-stembuild-test/$ENV:OVA_FILE" test.ova

Write-Host ***Cloning stembuild***
cd $ROOT_DIR
Copy-Item stembuild $STEMBUILD_DIR -Recurse -Force


Write-Host ***Building ginkgo***
go get github.com/onsi/ginkgo/ginkgo
go get -u github.com/vmware/govmomi/govc

Write-Host ***Building Stembuild***
cd $STEMBUILD_DIR
go generate
go install
go build -o out/stembuild.exe
$env:PATH="$GO_DIR/bin;$env:PATH"

# run tests
Write-Host ***Runninng integration tests***
govc import.ova --options=<(echo $JSON_TEMPLATE) --name=stembuild_linux --folder=$ENV:VCENTER_VM_FOLDER $ROOT_DIR/test.ova

ginkgo -r -randomizeAllSpecs integration/construct
if ($lastexitcode -ne 0)
{
  throw "integration specs failed"
}

$ErrorActionPreference = "silentlycontinue"
$val=1
# ADD SOME SORT OF WAIT????
while($val -ne 0) { govc vm.info --vm.ip=$ENV:EXISTING_VM_IP ; $val=$LASTEXITCODE }
$ErrorActionPreference = "Stop";
govc vm.destroy --vm.ip=$ENV:EXISTING_VM_IP
