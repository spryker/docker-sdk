#!/bin/bash

# shellcheck disable=SC2164
pushd "${BASH_SOURCE%/*}" >/dev/null
. ../../console.sh
popd >/dev/null

function printLogo() {
    echo -e "${GREEN}"
    echo -e "oooooooooo.                       oooo                                  .oooooo.   ooooo        ooooo "
    echo -e "\`888'   \`Y8b                      \`888                                 d8P'  \`Y8b  \`888'        \`888' "
    echo -e " 888      888  .ooooo.   .ooooo.   888  oooo   .ooooo.  oooo d8b      888           888          888  "
    echo -e " 888      888 d88' \`88b d88' \`\"Y8  888 .8P'   d88' \`88b \`888\"\"8P      888           888          888  "
    echo -e " 888      888 888   888 888        888888.    888ooo888  888          888           888          888  "
    echo -e " 888     d88' 888   888 888   .o8  888 \`88b.  888    .o  888          \`88b    ooo   888       o  888  "
    echo -e "o888bood8P'   \`Y8bod8P' \`Y8bod8P' o888o o888o \`Y8bod8P' d888b          \`Y8bood8P'  o888ooooood8 o888o "
    echo -e "${NC}"
}

printLogo
