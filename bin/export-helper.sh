#!/usr/bin/env bash

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
