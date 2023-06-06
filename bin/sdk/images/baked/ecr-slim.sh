#!/bin/bash
set -eo

import sdk/images/common-slim.sh

function Images::buildApplication() {
    Console::start "Building application images for AWS ECR"
    Images::_buildApp
    Console::end "[DONE]"
}

function Assets::build() {
    Console::start "Building assets for AWS ECR"
    Images::_buildAssets
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
}

function Images::tagFrontend() {
    Console::verbose "${INFO}Tagging Frontend for AWS ECR${NC}"

    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    docker tag "${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-frontend:${tag}"
    docker tag "${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}" "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-frontend:latest"

}

function Images::push() {
    Console::verbose "${INFO}Pushing images to AWS ECR${NC}"
    local tag=${1:-${SPRYKER_DOCKER_TAG}}

    docker images | grep ecr
    for application in "${SPRYKER_APPLICATIONS[@]}"; do
        local application="$(echo "$application" | tr '[:upper:]' '[:lower:]')"
        echo "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-${application}:${tag}"
        docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-${application}:${tag}"
        docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-${application}:latest"
    done
        echo "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-frontend:${tag}"
        docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-frontend:${tag}"
        docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-frontend:latest"
        echo "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-jenkins:${tag}"
        docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-jenkins:${tag}"
        docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-jenkins:latest"
        echo "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-pipeline:${tag}"
        docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-pipeline:${tag}"
        docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-pipeline:latest"

        docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SPRYKER_PROJECT_NAME}-cache:latest"
}
