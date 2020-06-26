#!/bin/bash

# shellcheck disable=SC2164
pushd "${BASH_SOURCE%/*}" >/dev/null
. ../console.sh
popd >/dev/null

function printLogo() {

    if [ "$(command -v tput >/dev/null 2>&1 && tput colors 2>/dev/null || echo 0)" -gt 0 ]; then
        local GREEN="\033[1;32m"
        local RED="\033[1;31m"
        local NC="\033[0m" # No Color
    fi

    echo -e "${RED}"
    echo -e " (                                    (   (        )  "
    echo -e " )\ )                   )             )\ ))\ )  ( /(  "
    echo -e "(()/(       (   (    ( /(   (  (     (()/(()/(  )\()) "
    echo -e " /(_))   )  )(  )\ ) )\()) ))\ )(     /(_))(_))((_)\  "
    echo -e "(_))  /(/( (()\(()/(((_)\ /((_|()\   (_))(_))_|_ ((_) "
    echo -e "${GREEN}/ __|${RED}((_)_\ ((_))(_)) |(_|_))  ((_)  ${GREEN}/ __||   \ |/ /  "
    echo -e "\__ \| '_ \) '_| || | / // -_)| '_|  \__ \| |) |' <   "
    echo -e "|___/| .__/|_|  \_, |_\_\\___||_|     |___/|___/_|\_\  "
    echo -e "     |_|        |__/               ${NC}"
}

printLogo
