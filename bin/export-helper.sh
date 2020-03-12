#!/bin/bash

pushd "${BASH_SOURCE%/*}" > /dev/null
. ./console.sh
popd > /dev/null

function assertDestinationDirectory() {
    if [ ! -d "${1}" ] || [ ! -w "${1}" ];
    then
        error "${WARN}Directory '${1}' is not accessible. Please, make sure it does exist and has appropriate permissions.${NC}" > /dev/stderr
        exit 1
    fi
}

function doExport()
{
    local subCommand=${1}
    shift 1

    local tag=${SPRYKER_DOCKER_TAG}
    local destinationPath=${PROJECT_DIR}

    while getopts "t:p:" opt; do
        case ${opt} in
            t)
                tag=${OPTARG}
            ;;
            p)
                destinationPath=${OPTARG}
            ;;
            *) ;;
        esac
    done

    case ${subCommand} in
        asset|assets)
            assertDestinationDirectory "${destinationPath}" 1>&2
            doBaseImage 1>&2
            buildAssets "" "production" 1>&2
            exportAssets "${tag}" "${destinationPath}"
        ;;
        image|images)
            buildBaseImages 1>&2
            tagProdLikeImages "${tag}"
        ;;
        *)
            error "${WARN}Unknown command '${subCommand}' is occured. No action.${NC}" > /dev/stderr
            exit 1
            ;;
    esac
}

export -f doExport
