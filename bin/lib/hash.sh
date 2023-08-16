#!/bin/bash

function Hash::getHashForPath() {
    local path="${1}"
    local hash=''

    if [ ! -d "${path}" ]; then
        hash=$(md5sum "${path}" | awk '{ print $1 }')
        echo "${hash}"

        return
    fi

    hash=$(tar -cf - -C "${path}" . | md5sum | awk '{ print $1 }')

    echo "${hash}"
}

function Hash::isHashChanged() {
    local path="${1}"
    local hashDirPath="${DATA_DIR}/hash"

    local hash_file_name=$(echo "${path}" | md5sum | awk '{ print $1 }')
    local target_file_path="${hashDirPath}/${hash_file_name}.hash"
    local hash="$(Hash::getHashForPath "${path}")"

    local previous_hash=''

    if [ ! -d "${hashDirPath}" ]; then
        mkdir -p "${hashDirPath}"
    fi

    if [ -f "${target_file_path}" ]; then
        previous_hash=$(cat "${target_file_path}")
    fi

    if [ "${hash}" == "${previous_hash}" ]; then
        return "${FALSE}"
    fi

    rm -f "${target_file_path}"
    touch "${target_file_path}"
    echo "${hash}" > "${target_file_path}"

    return "${TRUE}"
}
