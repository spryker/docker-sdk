#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ./constants.sh
. ./console.sh

function checkDockerProjectDirectory()
{
    local projectDirectoryPath="$( pwd )"

    if [ "${projectDirectoryPath}" != "${projectDirectoryPath%[[:space:]]*}" ]
    then
        verbose ""
        error "${WARN}Project directory contains spaces. Please remove spaces from the source directory name.${NC}"
        exit 1
    fi

  verbose "[OK]"
}

checkDockerProjectDirectory $@
