#!/bin/bash

function Platform::getPlatform() {
    local uname=$(uname)
    if [ "${uname}" == "Linux" ] && [ "$(uname -a | grep -c -v Microsoft | sed 's/^ *//')" -eq 1 ]; then
        echo "linux"
        return 0
    fi

    if [ "${uname}" == "Darwin" ]; then
        echo "macos"
        return 0
    fi

    echo "windows"
}

readonly _PLATFORM=$(Platform::getPlatform)
