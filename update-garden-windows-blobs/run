#!/bin/bash
set -ex

sha=$(ls garden-windows-bosh-artifacts/*.zip | sed s/.*-// | sed s/\.zip\//)
unzip -d garden-artifacts garden-windows-bosh-artifacts/*.zip
tar -czf garden-windows-$sha.tgz -C garden-artifacts/bosh-executables .

pushd release


ruby -e '
require "yaml"
file_name = "config/blobs.yml"
result=YAML.load_file(file_name)
result = result.reject {|x| x.include?("garden-windows")}
File.open(file_name, "w") {|f| f.write result.to_yaml }
'

bosh add blob ../garden-windows-$sha.tgz garden-windows

if [ -n "$ACCESS_KEY_ID" -a -n "$SECRET_ACCESS_KEY" ]; then
  cat > config/private.yml << EOF
---
blobstore:
  s3:
    access_key_id: $ACCESS_KEY_ID
    secret_access_key: $SECRET_ACCESS_KEY
EOF
  bosh -n upload blobs
  git config user.email "cf-netgarden-eng@pivotal.io"
  git config user.name "CI (Automated)"
  git commit config/blobs.yml -m "Update Windows bosh blobs"
else
  echo "No \$ACCESS_KEY_ID and \$SECRET_ACCESS_KEY provided, skipping blob upload/commit"
fi

popd

git clone release release-output
