#!/usr/bin/env bash

import sdk/images/baked.sh

function Images::buildApplication() {
    Console::verbose "${INFO}Building application images for AWS ECR${NC}"

    Images::_buildApp baked "${TRUE}"
}

function Images::buildFrontend() {
    Console::verbose "${INFO}Building Frontend image for AWS ECR${NC}"

    Images::_buildFrontend baked
    Images::_buildGateway
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
}

function Images::tagFrontend() {
    Console::verbose "${INFO}Tagging Frontend for AWS ECR${NC}"

    local tag=${1:-${SPRYKER_DOCKER_TAG}}
    local ecr_base="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

    docker tag "${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}" "${ecr_base}/${SPRYKER_PROJECT_NAME}-frontend:${tag}"
    docker tag "${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}" "${ecr_base}/${SPRYKER_PROJECT_NAME}-frontend:latest"
    
    local source_builder_assets_image="$(Assets::getImageTag)"
    local builder_assets_image="${ecr_base}/${SPRYKER_PROJECT_NAME}-builder_assets:${tag}"
    local builder_assets_latest="${ecr_base}/${SPRYKER_PROJECT_NAME}-builder_assets:latest"
    local repository_name="${SPRYKER_PROJECT_NAME}-builder_assets"
    local minimal_assets_image="${SPRYKER_DOCKER_PREFIX}_builder_assets_minimal:${SPRYKER_DOCKER_TAG}"
    
    if ! docker image inspect "${minimal_assets_image}" >/dev/null 2>&1; then
        Console::verbose "${INFO}Creating minimal builder_assets image (only /data/public)${NC}"
        echo "FROM scratch
COPY --from=${source_builder_assets_image} /data/public /data/public" | \
            docker build -t "${minimal_assets_image}" -f - . >/dev/null 2>&1
    fi
    
    if ! aws ecr describe-images --repository-name "${repository_name}" --image-ids imageTag=latest --region "${AWS_REGION}" &>/dev/null; then
        docker tag "${minimal_assets_image}" "${builder_assets_latest}"
    fi
}

function Images::push() {
    Console::verbose "${INFO}Pushing images to AWS ECR${NC}"
    local tag=${1:-${SPRYKER_DOCKER_TAG}}
    local ecr_base="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

    local all_images=(boffice)

    # for application in "${SPRYKER_APPLICATIONS[@]}"; do
        # all_images+=("$(echo "$application" | tr '[:upper:]' '[:lower:]')")
    # done

    all_images+=(frontend jenkins)

    for app in "${all_images[@]}"; do
        echo "${ecr_base}/${SPRYKER_PROJECT_NAME}-${app}:${tag}"
        docker push "${ecr_base}/${SPRYKER_PROJECT_NAME}-${app}:${tag}" &
        docker push "${ecr_base}/${SPRYKER_PROJECT_NAME}-${app}:latest" &
    done

    local repository_name="${SPRYKER_PROJECT_NAME}-builder_assets"
    if ! aws ecr describe-images --repository-name "${repository_name}" --image-ids imageTag=latest --region "${AWS_REGION}" &>/dev/null; then
        echo "${ecr_base}/${SPRYKER_PROJECT_NAME}-builder_assets:${tag}"
        docker push "${ecr_base}/${SPRYKER_PROJECT_NAME}-builder_assets:latest" &
    fi

    wait
}
