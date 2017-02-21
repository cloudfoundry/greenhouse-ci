#!/bin/bash

set -e

ACCOUNT_EMAIL=$(echo $ACCOUNT_JSON | jq -r .client_email)
PROJECT_ID=$(echo $ACCOUNT_JSON | jq -r .project_id)

gcloud auth activate-service-account --quiet $ACCOUNT_EMAIL --key-file <(echo $ACCOUNT_JSON)

set -x

image_id=$(gcloud compute images list --regexp windows-server-2012-r2-dc-v.* --format json | jq -r .[0].name)

printf $image_id > image/id

