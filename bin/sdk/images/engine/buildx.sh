#!/bin/bash

import sdk/images/engine/build.common.sh

function Images::_build::prepareArguments() {
    if Images::needPush; then
        echo '--push'
    fi
}

function Images::_build::afterTaggingAnImage() {
    :
}
