#!/bin/bash

Registry::require tr

declare -a HELP_REGISTRY

function Registry::Help::section() {

    Registry::Help::separator

    local sectionTitle=${1}
    HELP_REGISTRY+=("col0='${HELP_SEC}${sectionTitle}${NC}'")
}

function Registry::Help::separator() {
    local col0=''
    HELP_REGISTRY+=("col0='${col0}'")
}

function Registry::Help::command() {
    local OPTIND=0
    local OPTARG=''
    local OPTERR=''
    local envs=''
    local command=''
    local arguments=''
    local showSelfScript=0
    local selfScript="${HELP_SCR}${SELF_SCRIPT}${NC}"

    while getopts "se:c:a:" opt; do
        case ${opt} in
            s) showSelfScript=1 ;;
            e) envs="${OPTARG} " && showSelfScript=1 ;;
            c) command=" ${OPTARG}" ;;
            a) arguments=" ${OPTARG}" ;;
            *) ;;
        esac
    done
    shift $((OPTIND - 1))

    [ "${showSelfScript}" == 0 ] && selfScript=''

    Registry::Help::row "" "${HELP_ENV}${envs}${NC}${HELP_SCR}${selfScript}${NC}${HELP_CMD}${command}${NC}${HELP_ARG}${arguments}${NC}" "${HELP_DESC}${*}${NC}"

    return "${TRUE}"
}

function Registry::Help::row() {
    local col0=$1
    local col1=$2
    local col2=$3

    HELP_REGISTRY+=("col0='${col0}'; col1='${col1}'; col2='${col2}'")

    return "${TRUE}"
}

function Registry::printHelp() {

    local -i padding=20

    for record in "${HELP_REGISTRY[@]}"; do
        local col0=''
        local col1=''
        local col2=''
        eval "${record}"

        local column1=$(String::removeColors "$col1")
        local column2=$(String::removeColors "$col2")
        local -i len=${#column1}

        [ -n "$column2" ] && [ "${len}" -gt "${padding}" ] && padding=${len}
    done

    for record in "${HELP_REGISTRY[@]}"; do
        local col0=''
        local col1=''
        local col2=''
        eval "${record}"

        local column=$(String::removeColors "$col1")
        local -i len=${#column}
        local -i padLength=$((padding - len))
        local pad=$(printf "%-${padLength}.${padLength}s" ' ')

        echo -e "$col0 $col1${pad}  $col2"
    done

    return "${TRUE}"
}
