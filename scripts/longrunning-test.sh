#!/usr/bin/env bash

set -ex

appname=`mktemp noraXXXXX`
domain=greenhouse-development2.cf-app.com
url=$appname.$domain

function cleanup {
  if [ $? -eq 0 ]; then
    return
  fi
  cf d "$appname" -r -f >/dev/null 2>&1 || echo "could not kill app"
}
trap "cleanup" EXIT

# Assumes diego-windows-msi under ./diego-windows-msi
export nora_dir=$PWD/wats
function cf {
    ${nora_dir}/bin/cf-linux "$@"
}

export -f cf

cf api --skip-ssl-validation api.$domain
cf login -u $CF_USERNAME -p $CF_PASSWORD -o ORG -s SPACE
cf delete-orphaned-routes -f

pushd ${nora_dir}/assets/nora
  ./make_a_nora $appname
popd

cf scale -f -i 3 $appname

for i in {1..300}; do
    count=`cf app $appname | grep running | wc -l`
    if [ $count -eq 3 ]; then
        break;
    fi
    sleep 1
done

if [ $count -ne 3 ]; then
    echo "scaling failed"
    exit 1
fi

# TODO: make sure we hit all three instances
for i in {1..10}; do
    curl $url
done

function background_curl() {
    while [ $? -eq 0 ]; do
        curl -sf $url
    done
}

background_curl &

cf d $appname -r -f

source ./greenhouse-private/longrunning/bootstrap_environment
target_ip=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" | jq -r '.Reservations | map(select(.Instances[].Platform == "windows"))[0] | .Instances[0] | .PrivateIpAddress')
export TARGET_URL="http://$target_ip:8080"
export SSH_KEY=$(cat greenhouse-private/longrunning/keypair/id_rsa_bosh)

greenhouse-ci/scripts/run-monitor-health.rb
