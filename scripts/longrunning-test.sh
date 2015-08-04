#!/usr/bin/env bash

set -ex

# Assumes diego-windows-msi under ./diego-windows-msi

nora_dir=diego-windows-msi/src/github.com/pivotal-cf-experimental/nora
appname=nora
domain=greenhouse-development2.cf-app.com
url=$appname.$domain

cf="${nora_dir}/bin/cf-linux"
$cf api api.$domain
$cf login -u $CF_USERNAME -p $CF_PASSWORD

pushd ${nora_dir}/assets/nora
  ./make_a_nora $appname
popd

$cf scale -i 3 $appname
for i in {1..10}; do
    curl $url
done
$cf d $appname
