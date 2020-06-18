#!/bin/bash

Registry::addCommand "export" "Command::export"

Registry::Help::command -c "export images" -a "[-t <tag>]" "Builds prod-like images (Yves, Zed, Glue, Cli)."
Registry::Help::command -c "export assets" -a "[-t <tag>] [-p <path>]" "Builds assets and export as archives stored by given path."

function _assertDestinationDirectory() {
    if [ ! -d "${1}" ] || [ ! -w "${1}" ]; then
        Console::error "${WARN}Directory '${1}' is not accessible. Please, make sure it does exist and has appropriate permissions.${NC}"
        exit 1
    fi
}

function Command::export() {
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
            *) ;;
        esac
    done

    case ${subCommand} in
        asset | assets)
            _assertDestinationDirectory ${destinationPath}
            Images::build
            Assets::build
            Assets::export ${tag} ${destinationPath}
            ;;
        image | images)
            Images::build
            Images::tagAll ${tag}
            ;;
    esac
}
