#!/usr/bin/env bash

set -e

VHD_DIR="vhd"
VHD_FILENAME=$(find ${VHD_DIR}/*.vhd -printf "%f")

if [ -z "${VHD_FILENAME}" ]
then
  echo "Unable to find any vhd file in ${VHD_DIR}"
  exit 1
fi

case "${OS_VERSION}" in

"2012R2")
  VHD_VERSION=$(echo "${VHD_FILENAME}" | sed 's/en.2k12r2.serverdatacenter.rtm.fpp.patched-//g' | sed 's/.vhd//g')
  ;;
1709|1803)
  VHD_VERSION=$(echo "${VHD_FILENAME}" | sed -E 's/Windows-Server-Datacenter-Core-.+-with-Containers-(.+)-en.*/\1/g')
  ;;
*)
  echo "OS Version needs to be 2012R2, 1709, 1803, is: ${OS_VERSION}" >&2
  exit 1
  ;;
esac

if [ -z "${VHD_VERSION}" ]
then
  echo "Unable to extract vhd version from filename: ${VHD_FILENAME}, this is required" >&2
  exit 1
fi

VERSION=$(cat version/version)

echo "Installing OVFTool..."
cp ovftool/VMware-ovftool-*-lin.x86_64.bundle ovftool/ovftool.bundle
chmod a+x ovftool/ovftool.bundle
ovftool/ovftool.bundle --eulas-agreed --required
echo ".. done installing OVFTool"
echo -e "\n\n"

echo "Updating stempatch to be executable"
cp stempatch/stempatch-linux-x86_64-* stempatch/stempatch
chmod a+x stempatch/stempatch
echo -e "\n\n"

PUBLISH_OS_VERSION="${OS_VERSION}"
if [ "${PUBLISH_OS_VERSION}" == "1709" ]
then
  PUBLISH_OS_VERSION="2016"
fi

MANIFEST_FILE=patchfile-manifest/patchfile-${VERSION}-${VHD_VERSION}.yml

echo "Building stemcell from patch file ..."
stempatch/stempatch -output $OUTPUT_DIR -vhd vhd/${VHD_FILENAME} apply-patch $MANIFEST_FILE
mv $OUTPUT_DIR/*.tgz $OUTPUT_DIR/bosh-stemcell-$(cat version/version)-patch-vsphere-esxi-windows${PUBLISH_OS_VERSION}-go_agent.tgz
echo "... done building stemcell from patch file"
