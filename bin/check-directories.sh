#!/bin/bash

set -e

pushd "${BASH_SOURCE%/*}" > /dev/null
. ./constants.sh
. ./console.sh
popd > /dev/null

function checkDirectories()
{
    local projectDirectoryPath="${1:-$( pwd )}"

    if [ "${projectDirectoryPath}" != "${projectDirectoryPath%[[:space:]]*}" ];
    then
        error "${WARN}The SDK does not support spaces in the path. Please, move your project accordingly.${NC}"
        exit 1
    fi
}

export -f checkDirectories
