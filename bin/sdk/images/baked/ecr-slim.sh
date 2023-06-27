#!/bin/bash
set -eo

import sdk/images/common-slim.sh

function Images::buildApplication() {
    Console::start "Building application images for AWS ECR"
    Images::_buildApp
    Console::end "[DONE]"
}

function Images::importNodeCache() {
    Console::start "Building node cache image"
    Images::_importNodeCache
    Console::end "[DONE]"
}

function Assets::build() {
    Console::start "Building assets for AWS ECR"
    Images::_buildAssets
    Assets::_tagAssets
    Console::end "[DONE]"
}

function Images::buildFrontend() {
    Console::start "Building Frontend image for AWS ECR"
    Images::_buildFrontend
    Console::end "[DONE]"
}

function Images::tagApplications() {
    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    Console::verbose "${INFO}Tag images for AWS ECR${NC}"
    for application in "${SPRYKER_APPLICATIONS[@]}"; do
        local application="$(echo "$application" | tr '[:upper:]' '[:lower:]')"
        docker tag "${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-${application}:${tag}"
        docker tag "${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-${application}:latest"
    done

    docker tag "${SPRYKER_DOCKER_PREFIX}_jenkins:${SPRYKER_DOCKER_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-jenkins:${tag}"
    docker tag "${SPRYKER_DOCKER_PREFIX}_jenkins:${SPRYKER_DOCKER_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-jenkins:latest"
    docker tag "${SPRYKER_DOCKER_PREFIX}_pipeline:${SPRYKER_DOCKER_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-pipeline:${tag}"
    docker tag "${SPRYKER_DOCKER_PREFIX}_pipeline:${SPRYKER_DOCKER_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-pipeline:latest"

    docker tag "${SPRYKER_DOCKER_PREFIX}_composer_cache:${SPRYKER_DOCKER_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:composer-cache-latest"
}

function Assets::_tagAssets() {
    local tag=${SPRYKER_DOCKER_TAG}

    docker tag "${SPRYKER_DOCKER_PREFIX}_node_cache:${SPRYKER_DOCKER_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:node-cache-latest"
}

function Images::tagFrontend() {
    Console::verbose "${INFO}Tagging Frontend for AWS ECR${NC}"

    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    docker tag "${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-frontend:${tag}"
    docker tag "${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-frontend:latest"

}

function Images::pushApplications() {
    Console::verbose "${INFO}Pushing Jenkins, Pipeline and backend application images to AWS ECR${NC}"
    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    echo "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:composer-cache-latest"
    Images::push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:composer-cache-latest" &

    Images::push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-jenkins:${tag}" &
    Images::push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-pipeline:${tag}" &
    for application in "${SPRYKER_APPLICATIONS[@]}"; do
        local application="$(echo "$application" | tr '[:upper:]' '[:lower:]')"
        Images::push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-${application}:${tag}" &
    done
#    wait

    Images::push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-jenkins:latest" &
    Images::push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-pipeline:latest" &
    for application in "${SPRYKER_APPLICATIONS[@]}"; do
        local application="$(echo "$application" | tr '[:upper:]' '[:lower:]')"
        Images::push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-${application}:latest" &
    done
#    wait
}

function Images::pushAssets() {
    Console::verbose "${INFO}Pushing assets cache to AWS ECR${NC}"
    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    echo "Pushing assets to ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:node-cache-latest"
    Images::push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:node-cache-latest" &
}

function Images::pushFrontend() {
    Console::verbose "${INFO}Pushing frontend image to AWS ECR${NC}"
    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    Images::push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-frontend:${tag}" &
#    wait
    Images::push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-frontend:latest" &
#    wait
}

function Images::push() {
    local image_tag=${1}

    if [ -z "${SKOPEO_IMAGE_PUSH}" ] ; then
        docker push "$image_tag"
    else
        skopeo copy --format oci --dest-precompute-digests --dest-compress-format zstd --dest-compress-level 1 docker-daemon:"${image_tag}" docker://"${image_tag}"
    fi
}
