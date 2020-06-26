#!/bin/bash

# shellcheck disable=SC2164
pushd "${BASH_SOURCE%/*}" >/dev/null
. ../console.sh
popd >/dev/null

function printLogo() {

    if [ "$(command -v tput >/dev/null 2>&1 && tput colors 2>/dev/null || echo 0)" -gt 0 ]; then
        local DGRAY="\033[1;90m"
        local NC="\033[0m" # No Color
    fi

    echo -e "${DGRAY}"
    echo -e "  ___               _              ___ ___  _  __"
    echo -e " / __|_ __ _ _ _  _| |_____ _ _   / __|   \| |/ /"
    echo -e " \__ \ '_ \ '_| || | / / -_) '_|  \__ \ |) | ' < "
    echo -e " |___/ .__/_|  \_, |_\_\___|_|    |___/___/|_|\_\\"
    echo -e "     |_|       |__/                              "
    echo -e "${NC}"
}

printLogo
