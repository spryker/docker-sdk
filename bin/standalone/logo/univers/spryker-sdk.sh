#!/bin/bash

# shellcheck disable=SC2164
pushd "${BASH_SOURCE%/*}" >/dev/null
. ../../console.sh
popd >/dev/null

function printLogo() {
    echo -e "${GREEN}"
    echo -e "88888888ba,                             88                                    ad88888ba   88888888ba,    88      a8P   "
    echo -e "88      \`\"8b                            88                                   d8\"     \"8b  88      \`\"8b   88    ,88'    "
    echo -e "88        \`8b                           88                                   Y8,          88        \`8b  88  ,88\"      "
    echo -e "88         88   ,adPPYba,    ,adPPYba,  88   ,d8   ,adPPYba,  8b,dPPYba,     \`Y8aaaaa,    88         88  88,d88'       "
    echo -e "88         88  a8\"     \"8a  a8\"     \"\"  88 ,a8\"   a8P_____88  88P'   \"Y8       \`\"\"\"\"\"8b,  88         88  8888\"88,      "
    echo -e "88         8P  8b       d8  8b          8888[     8PP\"\"\"\"\"\"\"  88                     \`8b  88         8P  88P   Y8b     "
    echo -e "88      .a8P   \"8a,   ,a8\"  \"8a,   ,aa  88\`\"Yba,  \"8b,   ,aa  88             Y8a     a8P  88      .a8P   88     \"88,   "
    echo -e "88888888Y\"'     \`\"YbbdP\"'    \`\"Ybbd8\"'  88   \`Y8a  \`\"Ybbd8\"'  88              \"Y88888P\"   88888888Y\"'    88       Y8b  "
    echo -e "${NC}"
}

printLogo








