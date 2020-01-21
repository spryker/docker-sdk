#!/bin/bash

set -e

APPLICATIONS=(Glue Yves Zed)
PROJECT_DIR=${PROJECT_DIR:-$(pwd)}
SPRYKER_DOCKER_TAG=${SPRYKER_DOCKER_TAG:-'1.0'}

tag=${1:-${SPRYKER_DOCKER_TAG}}
destinationPath=${2%/}

for application in "${APPLICATIONS[@]}";
do
    assetsPath=${PROJECT_DIR}/public/${application}/assets/

    if [ -d "${assetsPath}" ];
    then
        tarName=${application}-${tag}.tar
        tar czf "${destinationPath}/${tarName}" -C "${assetsPath}" .
    fi
done
