#!/usr/bin/env bash

set -ex

# Assumes diego-windows-msi under ./diego-windows-msi

appname=nora
domain=greenhouse-development2.cf-app.com
url=$appname.$domain

cf api api.$domain
cf login -u $CF_USERNAME -p $CF_PASSWORD

pushd diego-windows-msi/src/github.com/pivotal-cf-experimental/nora/assets/nora
  ./make_a_nora $appname
popd

cf scale -i 3 $appname
for i in {1..10}; do
    curl $url
done
cf d $appname
