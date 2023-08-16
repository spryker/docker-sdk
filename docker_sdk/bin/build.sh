#!/bin/bash

function SDK::Codebase::Image::build() {
    local context="${SOURCE_DIR}"
    local tag="spryker_docker_sdk_codebase"
    local dockerfile="${SDK_DIR}/Dockerfile"

    Image::build "${context}" "${tag}" "${SDK_DIR}" "${dockerfile}"
}
