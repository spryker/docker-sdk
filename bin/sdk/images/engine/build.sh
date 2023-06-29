#!/bin/bash

import sdk/images/engine/build.common.sh

function Images::_build::prepareArguments() {
    :
}

function Images::_build::afterTaggingAnImage() {
set -x
    local -a tagsToPush=("${@}")

    if Images::needPush; then
        local tag
        for tag in "${tagsToPush[@]}"; do
            docker push ${tag}
        done
    fi
}
