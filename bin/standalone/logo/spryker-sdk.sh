#!/bin/bash

# shellcheck disable=SC2164
pushd "${BASH_SOURCE%/*}" >/dev/null
. ../console.sh
popd >/dev/null

function printLogo() {
    echo -e "${GREEN}"
    echo -e " _____             _                _____ _____  _  __"
    echo -e "|  __ \           | |              / ____|  __ \| |/ /"
    echo -e "| |  | | ___   ___| | _____ _ __  | (___ | |  | | ' / "
    echo -e "| |  | |/ _ \ / __| |/ / _ \ '__|  \___ \| |  | |  <  "
    echo -e "| |__| | (_) | (__|   <  __/ |     ____) | |__| | . \ "
    echo -e "|_____/ \___/ \___|_|\_\___|_|    |_____/|_____/|_|\_\\"
    echo -e "${NC}"
}

printLogo
