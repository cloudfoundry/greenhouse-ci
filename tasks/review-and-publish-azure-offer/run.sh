#!/usr/bin/env bash

set -euo pipefail

create_microsoft_token() {
  tenant_id=${PARTNER_PORTAL_TENANT_ID}
  client_id=${PARTNER_PORTAL_CLIENT_ID}
  client_secret=${PARTNER_PORTAL_CLIENT_SECRET}
  grant_type="client_credentials"
  resource="https://cloudpartner.azure.com"

  microsoft_auth_endpoint="https://login.microsoftonline.com/$tenant_id/oauth2/token"
  token=$(curl -X POST $microsoft_auth_endpoint \
    -F "client_id=$client_id"  \
    -F "client_secret=$client_secret"  \
    -F "grant_type=$grant_type"  \
    -F "resource=$resource" | jq -r .access_token
  )
  echo $token
}

save_offer_draft {

}

review_and_publish_offer {

}