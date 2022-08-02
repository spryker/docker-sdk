#!/bin/bash

# shellcheck disable=SC2164
pushd "${BASH_SOURCE%/*}" >/dev/null
. ../console.sh
popd >/dev/null

function printLogo() {
    echo -e "${GREEN}"
    echo -e "┌────╮       ┌─┐           ╭────┬────╮─┬─┐"
    echo -e "│  ╮ │───┬───┤ ├─┬───┬─┬─┐ │ ───┤  ╮ │ ┌─┘"
    echo -e "│  ╯ │ ┼ │ ├─┤───┤ ┼─┤ ┌─╯ ├─── │  ╯ │ └─┐"
    echo -e "└────┴───┴───┴─┴─┴───┴─┘   └────┴────┴─┴─┘"
    echo -e "                                          "
    echo -e "${NC}"
}

printLogo
