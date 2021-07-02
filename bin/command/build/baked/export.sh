#!/bin/bash

Registry::addCommand "export" "Command::export"

Registry::Help::command -c "export images" -a "[-t <tag>]" "Builds prod-like images (Yves, Zed, Glue, Frontend)."
Registry::Help::command -c "export assets" -a "[-t <tag>] [-p <path>]" "[DEPRECATED] Builds assets and export as archives stored by given path."

function _assertDestinationDirectory() {
    if [ ! -d "${1}" ] || [ ! -w "${1}" ]; then
        Console::error "${WARN}Directory '${1}' is not accessible. Please, make sure it does exist and has appropriate permissions.${NC}"
        exit 1
    fi
}

function Command::export() {
    local subCommand=''
    local tag=${SPRYKER_DOCKER_TAG}
    local destinationPath='./'

    subCommand=${1}
    shift || true

    while getopts "t:p:" opt; do
        case "${opt}" in
            t)
                tag=${OPTARG}
                ;;
            p)
                # Deprecated
                destinationPath=${OPTARG}
                ;;
            # Unknown option specified
            \?)
                Registry::printHelp
                Console::error "\nUnknown option ${INFO}-${OPTARG}${WARN} is acquired."
                exit 1
                ;;
            # Specified argument without required value
            :)
                Registry::printHelp
                Console::error "Option ${INFO}-${OPTARG}${WARN} requires an argument."
                exit 1
                ;;
            *)
                echo ${opt}
                ;;
        esac
    done
    shift $((OPTIND - 1))

    case ${subCommand} in
        asset | assets)
            Console::warn 'This command is DEPRECATED. Please, use just "export".'
            _assertDestinationDirectory "${destinationPath}"
            Images::buildApplication --force
            Assets::build --force
            Images::buildFrontend --force
            Assets::export "${tag}" "${destinationPath}"
            ;;
        image | images)
            Images::buildApplication --force
            Images::tagApplications "${tag}"
            Assets::build --force
            Images::buildFrontend --force
            Images::tagFrontend "${tag}"
            Images::printAll "${tag}"
            ;;
        *)
            Console::error "Unknown export '${subCommand}' is occurred. No action. Usage: ${HELP_SCR}${SELF_SCRIPT} export images [-t <tag>]" >&2
            exit 1
            ;;
    esac
}
