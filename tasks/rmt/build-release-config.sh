#!/usr/bin/env bash

set -eux

version=$( cat version/version | cut -d '.' -f1-2 )

docs_link="https://docs.vmware.com/en/Stemcells-for-VMware-Tanzu/services/release-notes/windows-stemcell-v2019x.html"
today="$(date '+%m/%d/%Y')"

cat <<-EOF >./release-config/release.yml
---
business_unit: Tanzu and Cloud Health
contact: ${RELEASE_CONTACT}
title: ${RELEASE_TITLE}
product_name: ${RELEASE_PRODUCT_NAME}
display_group: ${RELEASE_DISPLAY_GROUP}
version: ${version}
type: ${RELEASE_TYPE}
status: ${RELEASE_STATUS}
lang: EN
docs_link: "${docs_link}"
ga_date_mm/dd/yyyy: ${today}
published_date_mm/dd/yyyy: ${today}
end_of_support_date_mm/dd/yyyy: ${RELEASE_END_OF_SUPPORT}
export_control_status: SCREENING_REQUIRED
upgrade_specifiers:
- specifier: ${RELEASE_UPGRADE_SPECIFIER}
EOF

declare -A iaases
iaases=(
  ["aws"]="AWS"
  ["gcp"]="GCP"
  ["azure"]="Azure"
)

printf 'files:\n' >> ./release-config/release.yml
for iaas in "${!iaases[@]}"; do
  stemcell_dir="${iaas}-stemcell-final"
  cp "${stemcell_dir}"/*.tgz release-files/
  cat <<EOF >>./release-config/release.yml
- file: "../release-files/$(basename "${stemcell_dir}"/*.tgz)"
  description: "${iaases[$iaas]} light Stemcell"
EOF
done

declare -A stembuilders
stembuilders=(
  ["linux"]="Linux"
  ["windows"]="Windows"
)

for os in "${!stembuilders[@]}"; do
  cp final-stembuilds/stembuild-${os}* release-files/
  cat <<EOF >>./release-config/release.yml
- file: "../release-files/$(basename final-stembuilds/stembuild-${os}*)"
  description: "vSphere Stembuild CLI - ${stembuilders[$os]}"
EOF
done

cp license-file/*.txt release-files/
cat <<EOF >>./release-config/release.yml
- file: "../release-files/$(basename "license-file"/*.txt)"
  description: "Stemcells for PCF (Windows) License"
EOF

if [ -n "$RELEASE_SKU" ]; then
  cat <<SKUS >>./release-config/release.yml
skus:
- code: ${RELEASE_SKU}
SKUS
fi

echo "RMT release file:"
cat release-config/release.yml