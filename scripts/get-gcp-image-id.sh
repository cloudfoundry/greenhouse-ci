#!/bin/bash

set -e

ACCOUNT_EMAIL=$(echo $ACCOUNT_JSON | jq -r .client_email)
PROJECT_ID=$(echo $ACCOUNT_JSON | jq -r .project_id)

gcloud auth activate-service-account --quiet $ACCOUNT_EMAIL --key-file <(echo $ACCOUNT_JSON)

set -x

base_image_regex=""
if [ "$BASE_OS"  == "windows2012R2" ]; then
  base_image_regex="windows-server-2012-r2-dc-v.*"
elif [ "$BASE_OS" == "windows2016" ]; then
  base_image_regex="windows-server-2016-dc-v.*"
else
  echo "Define BASE_OS environment variable (e.g. windows2012R2,windows2016)" 1>&2
	exit 1
fi

image_id=$(gcloud compute images list --regexp ${base_image_regex} --format json | jq -r .[0].name)

printf $image_id > image/id

