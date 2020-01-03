#!/bin/bash

pushd "${BASH_SOURCE%/*}" > /dev/null
. ./console.sh
popd > /dev/null

function assertDestinationDirectory() {
    if [ ! -d ${1} ];
    then
        error "${WARN}Directory '${1}' is not accessible. Please, make sure it does exist and has appropriate permissions.${NC}"
        exit 1
    fi
}

function doExport()
{
    local subCommand=${1}
    shift 1

    local tag=''
    local destinationPath=''

    while getopts "t:p:" opt; do
        case ${opt} in
            t)
                tag=${OPTARG}
            ;;
            p)
                destinationPath=${OPTARG}
            ;;
        esac
    done

    case ${subCommand} in
        asset|assets)
            assertDestinationDirectory ${destinationPath}
            doBaseImage
            buildAssets
            exportAssets ${tag} ${destinationPath}
        ;;
        image|images)
            buildBaseImages ${tag}
            tagProdLikeImages ${tag}
        ;;
    esac
}

export -f doExport
