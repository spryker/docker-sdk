#!/bin/bash

set -e

pushd "${BASH_SOURCE%/*}" > /dev/null
. ../constants.sh
. ../console.sh
. ../images/main.sh
. ../images/baked.sh
popd > /dev/null

function buildCodeBase()
{
    verbose "${INFO}Building base application image${NC}"

    buildMainImage
    buildBaseImages
    tagProdLikeImages
}

export -f buildCodeBase
