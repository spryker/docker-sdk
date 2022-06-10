#!/bin/bash

Registry::addCommand "config" "Command::config"

Registry::Help::command -c "config" "Prebuild deploy.yml file."

function Command::config() {
    shift $((OPTIND - 1))
    local tmpDeploymentDir="${SOURCE_DIR}/deployment/_tmp"
    local defaultProjectYaml=$([ -f "./deploy.local.yml" ] && echo -n "./deploy.local.yml" || echo -n "./deploy.yml")
    local projectYaml=${1:-${defaultProjectYaml}}
    local projectDeployTemplatesDirectory="./config/deploy-templates/"

    if [ -d "${tmpDeploymentDir}" ]; then
        rm -rf "${tmpDeploymentDir}"
    fi
    mkdir "${tmpDeploymentDir}"

    tmpDeploymentDir="$(cd "${tmpDeploymentDir}" >/dev/null 2>&1 && pwd)"

    Command::bootstrap::_validateParameters

    Console::info "Using ${projectYaml}"

    local USER_FULL_ID=$(Environment::getFullUserId)

    Console::verbose::start "Building generator..."
    docker build -t spryker_docker_sdk \
        -f "${SOURCE_DIR}/generator/deploy-file-generator/Dockerfile" \
        --progress="${PROGRESS_TYPE:-auto}" \
        --build-arg="USER_UID=${USER_FULL_ID%%:*}" \
        -q \
        "${SOURCE_DIR}/generator" >/dev/null

    cp "${projectYaml}" "${tmpDeploymentDir}/project.yml"

    if [ -d "${projectDeployTemplatesDirectory}" ]; then
        cp -rf "${projectDeployTemplatesDirectory}" "${tmpDeploymentDir}/project-deploy-templates"
    fi
    Console::end "[DONE]"

    Console::info "${INFO}Running generator${NC}"

    # To support root user
    local userToRun=("-u" "${USER_FULL_ID}")
    if [ "${USER_FULL_ID%%:*}" != '0' ]; then
        userToRun=()
    fi
    docker run -i --rm "${userToRun[@]}" \
        -e SPRYKER_DOCKER_SDK_PLATFORM="${_PLATFORM}" \
        -e SPRYKER_DOCKER_SDK_DEPLOYMENT_DIR="${DESTINATION_DIR}" \
        -e VERBOSE="${VERBOSE}" \
        -v "${tmpDeploymentDir}":/data/deployment:rw \
        spryker_docker_sdk

    Console::end "[DONE]"
    rm -rf ${tmpDeploymentDir}

    return "${TRUE}"
}
