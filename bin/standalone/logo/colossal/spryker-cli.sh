#!/bin/bash

# shellcheck disable=SC2164
pushd "${BASH_SOURCE%/*}" >/dev/null
. ../../console.sh
popd >/dev/null

function printLogo() {
    echo -e "${GREEN}"
    echo -e '8888888b.                    888                             .d8888b.  888      8888888 '
    echo -e '888  "Y88b                   888                            d88P  Y88b 888        888   '
    echo -e '888    888                   888                            888    888 888        888   '
    echo -e '888    888  .d88b.   .d8888b 888  888  .d88b.  888d888      888        888        888   '
    echo -e '888    888 d88""88b d88P"    888 .88P d8P  Y8b 888P"        888        888        888   '
    echo -e '888    888 888  888 888      888888K  88888888 888          888    888 888        888   '
    echo -e '888  .d88P Y88..88P Y88b.    888 "88b Y8b.     888          Y88b  d88P 888        888   '
    echo -e '8888888P"   "Y88P"   "Y8888P 888  888  "Y8888  888           "Y8888P"  88888888 8888888 '
    echo -e "${NC}"
}

printLogo
