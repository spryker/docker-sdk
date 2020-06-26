#!/bin/bash

CONSOLE_STARTED=""

function Console::log() {
    Console::end
    echo -e "${@}"
    return 0
}

function Console::info() {
    Console::end
    echo -e "${INFO}"
    echo -e "${@}" "${NC}"
    return 0
}

function Console::start() {
    Console::end
    echo -e -n "${@}"
    CONSOLE_STARTED=$(date +%s)
    return 0
}

function Console::end() {
    if [ -n "${CONSOLE_STARTED}" ]; then
        local endTime=$(date +%s)
        echo -e " ${DGRAY}$((endTime - CONSOLE_STARTED))s${NC}" "${@}"
    fi
    CONSOLE_STARTED=""
    return 0
}

function Console::verbose() {
    Console::end ''
    [ "${VERBOSE}" == "1" ] && echo -e "${@}"
    return 0
}

function Console::verbose::start() {
    [ "${VERBOSE}" == "1" ] && Console::start "${@}"
    return 0
}

function Console::warn() {
    Console::end ''
    echo -e -n "${DECLARE}" >&2
    echo -e "${@}" "${NC}" >&2
    return 0
}

function Console::error() {
    Console::end ''
    echo -e -n "${WARN}" >&2
    echo -e "${@}" "${NC}" >&2
    return 0
}

# ------------------
# shellcheck disable=SC2034
function Console::setColors() {
    if tty >/dev/null && [ "$(command -v tput >/dev/null 2>&1 && tput colors 2>/dev/null || echo 0)" -gt 0 ]; then

        WHITE="\033[30m"
        RED="\033[31m"
        GREEN="\033[32m"
        OCHRE="\033[33m"
        BLUE="\033[34m"
        PLUM="\033[35m"
        CYAN="\033[36m"
        LGRAY="\033[37m"
        DGRAY="\033[90m"
        ROSE="\033[91m"
        LIME="\033[92m"
        YELLOW="\033[93m"
        PASTEL="\033[94m"
        MAGENTA="\033[95m"
        VIOLET="\033[96m"
        BLACK="\033[97m"

        BACKWHITE="\033[40m"
        BACKRED="\033[41m"
        BACKGREEN="\033[42m"
        BACKOCHRE="\033[43m"
        BACKBLUE="\033[44m"
        BACKPLUM="\033[45m"
        BACKCYAN="\033[46m"
        BACKLGRAY="\033[47m"
        BACKDGRAY="\033[100m"
        BACKROSE="\033[101m"
        BACKGREEN="\033[102m"
        BACKYELLOW="\033[103m"
        BACKPASTEL="\033[104m"
        BACKMAGENTA="\033[105m"
        BACKVIOLET="\033[106m"
        BACKBLACK="\033[107m"

        BOLD="\033[1m"
        DIM="\033[2m"
        ITALIC="\033[3m"
        UNDERLINE="\033[4m"

        NC="\033[0m"    # No Color
        CLEAR="\033[1K" # Clear everything from cursor to beginning of the line

        INFO=${OCHRE}
        WARN=${RED}
        DECLARE=${PLUM}
        OK=${GREEN}

        BLOCKLIGHT="${BACKLGRAY}${WHITE}\n\n"
        BLOCKDARK="${BACKDGRAY}${BLACK}\n\n"
        BLOCKYELLOW="${BACKYELLOW}${WHITE}\n\n"

        HELP_SEC="${OCHRE}"
        HELP_ENV="${CYAN}"
        HELP_SCR="${LGRAY}"
        HELP_CMD="${GREEN}"
        HELP_ARG=""
        HELP_DESC=""
        HELP_HIGH="${PLUM}"
    fi
}

Console::setColors
