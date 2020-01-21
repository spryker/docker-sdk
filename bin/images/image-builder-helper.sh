#!/bin/bash

function doTagByApplicationName()
{
    local applicationName=$1
    local imageName=$2
    local baseImageName=${3:-${2}}
    local applicationPrefix=$(echo "$applicationName" | tr '[:upper:]' '[:lower:]')

    docker tag "${baseImageName}" "${imageName}-${applicationPrefix}"

    echo -e "${INFO}Image for ${applicationName} application was created: ${imageName}-${applicationPrefix}${NC}"
}

export -f doTagByApplicationName
