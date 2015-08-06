#!/usr/bin/env bash

set -ex

appname=`mktemp noraXXXXX`
domain=greenhouse-development2.cf-app.com
url=$appname.$domain

function post_comment {
    exitcode=$?
    cf d $appname -f >/dev/null 2>&1 || echo "could not kill app"
    if [ $exitcode -eq 0 ]; then
        return
    fi
    curl -X POST -H "X-TrackerToken: ${TRACKER_TOKEN}" -H "Content-Type: application/json" \
         -d '{"text":"build failed"}' \
         "https://www.pivotaltracker.com/services/v5/projects/${TRACKER_PROJECT_ID}/stories/${TRACKER_STORY_ID}/comments"
}

# Assumes diego-windows-msi under ./diego-windows-msi
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

trap "post_comment" EXIT

# TODO: uncomment the scaling test, it's kind of flaky at the moment
# due to issues with diego on dev2

# cf scale -i 3 $appname

# for i in {1..300}; do
#     count=`cf app $appname | grep running | wc -l`
#     if [ $count -eq 3 ]; then
#         break;
#     fi
#     sleep 1
# done

# if [ $count -ne 3 ]; then
#     echo "scaling failed"
#     exit 1
# fi

# TODO: make sure we hit all three instances
for i in {1..10}; do
    curl $url
done

cf d $appname -f
sleep 3
greenhouse-ci/scripts/run-monitor-health.rb
