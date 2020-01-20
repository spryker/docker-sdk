#!/bin/bash

set -e

pushd "${BASH_SOURCE%/*}" > /dev/null
. ../constants.sh
. ../console.sh
. ../images/baked.sh
popd > /dev/null

function buildCodeBase()
{
    verbose "${INFO}Building base application image${NC}"

    buildBaseImages
    tagProdLikeImages
}

export -f buildCodeBase
