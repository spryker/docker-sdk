#!/bin/bash

function doTagByApplicationName()
{
    local applicationName=${1}
    local imageName=${2}
    local baseImageName=${3:-${imageName}}
    local applicationPrefix=$(echo "$applicationName" | tr '[:upper:]' '[:lower:]')
    local tag="${imageName}-${applicationPrefix}"

    docker tag "${baseImageName}" "${tag}"

    echo "${applicationName} ${tag}"
}

export -f doTagByApplicationName
