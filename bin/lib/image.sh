#!/bin/bash

function Image::isExist() {
    local tag="${1}"

    if [ -n "$(docker images -q "${tag}")" ]; then
        return "${TRUE}"
    fi

    return "${FALSE}"
}

function Image::build() {
    local contextPath="${1}"
    local tag="${2}"
    local hashTargets="${3}"
    local dockerfilePath="${4:-${contextPath}/Dockerfile}"
    local dockerArgs="${5:-}"

    if Hash::isHashChanged "${hashTargets}" || ! Image::isExist "${tag}"; then
        Console::start "${GREEN}Build \`"${tag}"\` image...${NC}"
        local output=$(docker build -q ${dockerArgs} -t "${tag}" -f "${dockerfilePath}" "${contextPath}" )

        if [ $? -ne 0 ]; then
            Console::error "Build \`"${tag}"\` image failed"
            echo "${output}"
            exit 1
        fi

        Console::end "[OK]"
    fi
}
