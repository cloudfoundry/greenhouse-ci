#!/usr/bin/env bash

set -ex

# Assumes diego-windows-msi under ./diego-windows-msi

appname=nora
domain=greenhouse-development2.cf-app.com
url=$appname.$domain

export nora_dir=$PWD/diego-windows-msi/src/github.com/pivotal-cf-experimental/nora
function cf {
    ${nora_dir}/bin/cf-linux "$@"
}

export -f cf

cf api --skip-ssl-validation api.$domain
cf login -u $CF_USERNAME -p $CF_PASSWORD -o ORG -s SPACE

pushd ${nora_dir}/assets/nora
  ./make_a_nora $appname
popd

trap "cf d $appname -f" EXIT

cf scale -i 3 $appname

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

for i in {1..10}; do
    curl $url
done

cf d $appname -f
