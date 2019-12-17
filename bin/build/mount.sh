#!/bin/bash

set -e

pushd "${BASH_SOURCE%/*}" > /dev/null
. ../constants.sh
. ../console.sh
. ../platform.sh
. ../images/mount.sh
popd > /dev/null

# TODO try execSpryker instead
function runApplicationBuild()
{
    local tty
    [ -t -0 ] && tty='t' || tty=''
    docker run -i${tty} --rm \
        -e COMMAND="$1" \
        -e SPRYKER_DB_ENGINE="${SPRYKER_DB_ENGINE}" \
        --restart=no \
        ${DOCKER_EXTRA_OPTIONS} \
        "${SPRYKER_DOCKER_PREFIX}_cli:${SPRYKER_DOCKER_TAG}" /usr/local/bin/execute.sh
}

function buildCode()
{
    sync create
    sync start
    sync stop

    [ "$1" = "${IF_NOT_PERFORMED}" ] && verbose "${INFO}Checking if anything should be built${NC}"

    runApplicationBuild 'chmod 600 /data/config/Zed/*.key'

    local vendorDirExist=$(runApplicationBuild '[ ! -f /data/vendor/bin/install ] && echo 0 || echo 1 | tail -n 1' | tr -d " \n\r")
    if [ "$1" != "${IF_NOT_PERFORMED}" ] || [ "${vendorDirExist}" == "0" ]; then
        verbose "${INFO}Running composer install${NC}"
        runApplicationBuild 'composer install --no-interaction --optimize-autoloader'
    fi

    local generatedDir=$(runApplicationBuild '[ ! -d /data/src/Generated ] && echo 0 || echo 1 | tail -n 1' | tr -d " \n\r")
    if [ "$1" != "${IF_NOT_PERFORMED}" ] || [ "${generatedDir}" == "0" ]; then
        verbose "${INFO}Running build${NC}"
        runApplicationBuild 'vendor/bin/install -r docker -s build -s build-development'
    fi

    if [ "$(getPlatform)" == 'windows' ];
    then
        # Fix the docker-sync permission issue on windows
        local executableFile=$(runApplicationBuild '[ ! -x $(readlink -f vendor/bin/console) ] && echo 0 || echo 1 | tail -n 1' | tr -d " \n\r")
        if [ "$1" != "${IF_NOT_PERFORMED}" ] || [ "${executableFile}" == "0" ];
        then
            runApplicationBuild 'chmod +x vendor/bin/*'
        fi
    fi
}

function buildCodeBase()
{
    if [ "$1" = "${IF_NOT_PERFORMED}" ] || [ "$(docker images -q "${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}" 2> /dev/null)" != "" ]; then
        return ${__TRUE}
    fi

    verbose "${INFO}Building base application image${NC}"

    buildBaseImages
    buildCode $1
}

export -f runApplicationBuild
export -f buildCodeBase
