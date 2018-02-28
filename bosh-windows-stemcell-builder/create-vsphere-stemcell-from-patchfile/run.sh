#!/usr/bin/env bash

set -e

VHD_VERSION=$(find 2012-vhd/*.vhd -printf "%f\n" | sed 's/en.2k12r2.serverdatacenter.rtm.fpp.patched-//g' | sed 's/.vhd//g')
VERSION=$(cat version/version)

echo "Installing OVFTool..."
cp ovftool/VMware-ovftool-*-lin.x86_64.bundle ovftool/ovftool.bundle
chmod a+x ovftool/ovftool.bundle
ovftool/ovftool.bundle --eulas-agreed --required
echo ".. done installing OVFTool"
echo -e "\n\n"

echo "Updating stembuild to be executable"
cp stembuild/stembuild-linux-x86_64-* stembuild/stembuild
chmod a+x stembuild/stembuild
echo -e "\n\n"

MANIFEST_FILE=patchfile-${VERSION}-${VHD_VERSION}.yml

mv patchfile-dir/patchfile-$VERSION-$VHD_VERSION .
echo "---" > $MANIFEST_FILE
echo "patch_file: patchfile-$VERSION-$VHD_VERSION" >> $MANIFEST_FILE
echo "os_version: $OS_VERSION" >> $MANIFEST_FILE
echo "output_dir: $OUTPUT_DIR" >> $MANIFEST_FILE
echo "vhd_file: $(ls 2012-vhd/*.vhd)" >> $MANIFEST_FILE
echo "version: $(cat version/version)" >> $MANIFEST_FILE
echo "Using following patchfile: "
cat $MANIFEST_FILE
echo -e "\n\n"

echo "Building stemcell from patch file ..."
stembuild/stembuild -output $OUTPUT_DIR apply-patch $MANIFEST_FILE
mv $OUTPUT_DIR/*.tgz $OUTPUT_DIR/bosh-stemcell-$(cat version/version)-patch-vsphere-esxi-windows2012R2-go_agent.tgz
mv $MANIFEST_FILE $OUTPUT_DIR
echo "... done building stemcell from patch file"
