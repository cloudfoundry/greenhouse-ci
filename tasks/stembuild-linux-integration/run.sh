#!/usr/bin/env bash

set -ex

VERSION=`cat stembuild-version/version`
ROOT_DIR=$(cd `dirname "${BASH_SOURCE[0]}"`/../../.. && pwd)
OUTPUT_DIR=${ROOT_DIR}/output

export EXISTING_VM_IP=`ls vcenter-ips/10.74.35.*`
echo "Using Exiting VM IP: ${EXISTING_VM_IP}"

JSON_TEMPLATE="{\"DiskProvisioning\": \"thin\",\"MarkAsTemplate\": false,\"Name\": \"stembuild_linux\",\"IPAllocationPolicy\": \"fixedPolicy\",\"IPProtocol\": \"IPv4\",\"NetworkMapping\": [{\"Name\": \"custom\",\"Network\": \"${GOVC_NETWORK}\"}],\"PropertyMapping\": [{\"Key\": \"ip0\",\"Value\": \"${EXISTING_VM_IP}\"},{\"Key\": \"cidr\",\"Value\": \"25\"},{\"Key\": \"gateway\",\"Value\": \"10.74.35.1\"},{\"Key\": \"DNS\",\"Value\": \"8.8.8.8\"}],\"PowerOn\": true,\"InjectOvfEnv\": false,\"WaitForIP\": false}"

echo ***Installing VMWare OVF Tools***
chmod +x ./ovftool/VMware-ovftool-4.2.0-5965791-lin.x86_64.bundle
./ovftool/VMware-ovftool-4.2.0-5965791-lin.x86_64.bundle --eulas-agreed --required

echo "***Creating GOPATH environment & structure ***"
export GOPATH=$PWD/gopath
export PATH=${GOPATH}/bin:$PATH

aws s3 cp "s3://${ROOT_BUCKET}/ova-for-stembuild-test/${OVA_FILE}" test.ova

CF_INC_DIR=${GOPATH}/src/github.com/cloudfoundry-incubator
STEMBUILD_DIR=${ROOT_DIR}/stembuild
mkdir -p ${CF_INC_DIR}
cp -r ${STEMBUILD_DIR} ${CF_INC_DIR}

# install ginkgo, govc
go get github.com/onsi/ginkgo/ginkgo
go get -u github.com/vmware/govmomi/govc

GO_STEMBUILD_DIR=${CF_INC_DIR}/stembuild
pushd ${GO_STEMBUILD_DIR}
  echo ***Test Stembuild Code***

  govc import.ova --options=<(echo ${JSON_TEMPLATE}) --name=stembuild_linux --folder=${VCENTER_VM_FOLDER} ${ROOT_DIR}/test.ova

  set +ex
  stat=1

  make integration
  stat=$?

  while [ $stat -ne 0 ]
  do
    govc vm.info --vm.ip=${EXISTING_VM_IP}
    stat=$?
  done
  set -ex
  govc vm.destroy --vm.ip=${EXISTING_VM_IP}

popd
