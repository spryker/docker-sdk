#!/bin/bash

set -e

pushd ${BASH_SOURCE%/*} > /dev/null
. ./constants.sh
. ./console.sh
. ./platform.sh

VERBOSE=0 ./require.sh docker tr
popd > /dev/null

function checkDockerComposeVersion()
{
    [ ! "$(getPlatform)" == "linux" ] && exit 0;

    local requiredMinimalVersion=${1:-'1.22.0'}
    local installedDockerComposerVersion=$(which docker-compose > /dev/null; test $? -eq 0 && docker-compose version --short || echo 0;)

    verbose -n "${INFO}Checking docker composer version...${NC}"

    if [ $(echo "${installedDockerComposerVersion}" | tr -d '.' | sed -E 's/[^0-9]+$//g') -lt $(echo "${requiredMinimalVersion}" | tr -d '.') ]
    then
        verbose ""
        error "${WARN}Docker Compose version ${installedDockerComposerVersion} is not supported. Please update Docker Compose to at least ${requiredMinimalVersion}.${NC}"
        exit 1
    fi

    verbose "[OK]"
}

checkDockerComposeVersion $@
