#!/bin/bash

set -e

ACCOUNT_EMAIL=$(echo $ACCOUNT_JSON | jq -r .client_email)
PROJECT_ID=$(echo $ACCOUNT_JSON | jq -r .project_id)

gcloud auth activate-service-account --quiet $ACCOUNT_EMAIL --key-file <(echo $ACCOUNT_JSON)

set -x

SERVICE_ACCOUNT_EMAIL=$(cat service-account/add)

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member "serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role "roles/$ROLE"
