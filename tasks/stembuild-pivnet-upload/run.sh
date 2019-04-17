#!/usr/bin/env bash

set -e

#API_TOKEN
#HOST
#FILE_GROUP_NAME
#PRODUCT_SLUG
#RELEASE


#SOURCE_FILE=/outdir/stembuild/stembuild.blah
#SOURCE_FILE_CONTAINING_DIR
#SOURCE_FILE_NAME


pivnet login --api-token=$API_TOKEN --host=$HOST

# create file group

FILE_GROUP_ID=$(pivnet --format=json create-file-group --product-slug=$PRODUCT_SLUG --name=$FILE_GROUP_NAME | jq .id)
pivnet add-file-group --product-slug=$PRODUCT_SLUG --file-group-id=$FILE_GROUP_ID --release-version=$RELEASE


# add product file to pivnet
SOURCE_DIR=./stembuild
FILENAME=$(basename $SOURCE_DIR/stembuild*windows*)

JSON_AWS_RESPONSE=$(curl -X POST https://pivnet-integration.cfapps.io/api/v2/federation_token -H "Authorization: Token pSD_BiQFgoMuhkddXysb" -d "{\"product_id\":\"$PRODUCT_SLUG\"}")
export AWS_ACCESS_KEY_ID=$(echo $JSON_AWS_RESPONSE | jq -r .access_key_id)
export AWS_SECRET_ACCESS_KEY=$(echo $JSON_AWS_RESPONSE | jq -r .secret_access_key)
export AWS_BUCKET=$(echo $JSON_AWS_RESPONSE | jq -r .bucket)
export AWS_REGION=$(echo $JSON_AWS_RESPONSE | jq -r .region)
export AWS_SESSION_TOKEN=$(echo $JSON_AWS_RESPONSE | jq -r .session_token)

#Can get product slug ID from here if need be
AWS_S3_DIRECTORY=$(pivnet --format=json product -p $PRODUCT_SLUG | jq -r .s3_directory.path)

aws s3 cp $SOURCE_DIR/$FILENAME "s3://$AWS_BUCKET$AWS_S3_DIRECTORY/$FILENAME"


FRIENDLY=$FILENAME
VERSION="7"
MD5=$(md5sum $SOURCE_DIR/$FILENAME | awk '{print $1}')
SHA256=$(sha256sum $SOURCE_DIR/$FILENAME | awk '{print $1}')
pivnet create-product-file --aws-object-key=$AWS_S3_DIRECTORY/$FILENAME --name $FRIENDLY --file-type="Software" --file-version=$VERSION --md5=$MD5 --sha256=$SHA256 --product-slug=$PRODUCT_SLUG

pivnet add-file-group
