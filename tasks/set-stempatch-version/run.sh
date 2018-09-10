#!/usr/bin/env bash

set -ex

RELEASE_VERSION=$( cat stempatch-version/version | cut -d '.' -f1-2 )
BIN_DIRS=( stempatch-untested-windows stempatch-untested-linux )

echo Releasing draft stempatch ${RELEASE_VERSION}

for DIR in "${BIN_DIRS[@]}"
do
    PLATFORM=$( echo ${DIR} | cut -d '-' -f3 )
    echo "*** Setting release version of ${PLATFORM} Stempatch ***"
    SOURCE_BINARY=$( find ${DIR} -name stempatch-\* -type f -printf "%f\n" )
    DEST_BINARY=$( echo ${SOURCE_BINARY} | sed -r 's/[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+/'${RELEASE_VERSION}'/g' )
    cp ${DIR}/${SOURCE_BINARY} output/${DEST_BINARY}
done

echo ${RELEASE_VERSION} > output/tag