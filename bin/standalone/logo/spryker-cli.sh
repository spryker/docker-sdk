#!/bin/bash

# shellcheck disable=SC2164
pushd "${BASH_SOURCE%/*}" >/dev/null
. ../console.sh
popd >/dev/null

function printLogo() {
    echo -e "${GREEN}"
    echo -e " _____             _                _____ _      _____ "
    echo -e "|  __ \           | |              / ____| |    |_   _|"
    echo -e "| |  | | ___   ___| | _____ _ __  | |    | |      | |  "
    echo -e "| |  | |/ _ \ / __| |/ / _ \ '__| | |    | |      | |  "
    echo -e "| |__| | (_) | (__|   <  __/ |    | |____| |____ _| |_ "
    echo -e "|_____/ \___/ \___|_|\_\___|_|     \_____|______|_____|"
    echo -e "${NC}"
}

printLogo
