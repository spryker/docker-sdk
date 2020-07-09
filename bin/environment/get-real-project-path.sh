#!/bin/bash

function Environment::getRealProjectPath() {
    local projectPath=${PROJECT_DIR:-$(pwd)}
    local mountPathPrefixForCatalinaOS="/System/Volumes/Data"

    if [ -d "${mountPathPrefixForCatalinaOS}${projectPath}" ]; then
        projectPath="${mountPathPrefixForCatalinaOS}${projectPath}"
    fi

    echo "${projectPath}"
}
