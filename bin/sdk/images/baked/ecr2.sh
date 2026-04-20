#!/usr/bin/env bash

import sdk/images/baked.sh

function Images::_composerLockHash() {
    md5sum composer.lock 2>/dev/null | cut -d' ' -f1 || md5 -q composer.lock 2>/dev/null
}

function Images::pullComposerCache() {
    local ecr_base="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    local repository_name="${SPRYKER_PROJECT_NAME}-composer_cache"
    local lockHash=$(Images::_composerLockHash)

    Console::start "Pulling composer cache from ECR..."

    if [ -n "${lockHash}" ]; then
        local hashImage="${ecr_base}/${repository_name}:${lockHash}"
        if docker pull "${hashImage}" >/dev/null 2>&1; then
            export SPRYKER_COMPOSER_CACHE_IMAGE="${hashImage}"
            Console::end "[FOUND] ${lockHash}"
            return "${TRUE}"
        fi
    fi

    Console::end "[NOT FOUND]"
    return "${FALSE}"
}

function Images::buildApplication() {
    Console::verbose "${INFO}Building application images for AWS ECR${NC}"

    Images::pullComposerCache || true
    Images::_buildApp baked "${TRUE}" "${TRUE}"
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
    
    local assetsLockHash=$(Assets::_packageLockHash)
    local assetsRepository="${SPRYKER_PROJECT_NAME}-builder_assets"

    if [ -n "${assetsLockHash}" ] && ! aws ecr describe-images --repository-name "${assetsRepository}" --image-ids imageTag="${assetsLockHash}" --region "${AWS_REGION}" &>/dev/null; then
        docker tag "${minimal_assets_image}" "${ecr_base}/${assetsRepository}:${assetsLockHash}"
        export SPRYKER_PUSH_ASSETS_CACHE="${TRUE}"
        Console::verbose "${INFO}Assets cache tagged: ${assetsLockHash} [NEW]${NC}"
    else
        Console::verbose "${INFO}Assets cache already exists for ${assetsLockHash} [SKIP]${NC}"
    fi

    local composerLockHash=$(Images::_composerLockHash)
    local composerRepository="${SPRYKER_PROJECT_NAME}-composer_cache"

    if [ -n "${composerLockHash}" ] && ! aws ecr describe-images --repository-name "${composerRepository}" --image-ids imageTag="${composerLockHash}" --region "${AWS_REGION}" &>/dev/null; then
        local composerCacheHash="${ecr_base}/${composerRepository}:${composerLockHash}"

        Console::start "Creating composer cache image..."
        if echo "FROM ${SPRYKER_PLATFORM_IMAGE} AS export
RUN --mount=type=cache,id=composer,sharing=locked,target=/composer-cache,uid=1000 \
    mkdir -p /export/cache && cp -a /composer-cache/. /export/cache/ 2>/dev/null || true

FROM scratch
COPY --from=export /export /
" | docker build -t "${composerCacheHash}" -f - . 2>&1; then
            export SPRYKER_PUSH_COMPOSER_CACHE="${TRUE}"
            Console::end "[DONE] ${composerLockHash} [NEW]"
        else
            Console::end "[SKIPPED] No composer cache found"
        fi
    else
        Console::verbose "${INFO}Composer cache already exists for ${composerLockHash} [SKIP]${NC}"
    fi
}

function Images::push() {
    Console::verbose "${INFO}Pushing images to AWS ECR${NC}"
    local tag=${1:-${SPRYKER_DOCKER_TAG}}
    local ecr_base="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

    local all_images=(boffice)
    all_images+=(frontend jenkins)

    for app in "${all_images[@]}"; do
        echo "${ecr_base}/${SPRYKER_PROJECT_NAME}-${app}:${tag}"
        docker push "${ecr_base}/${SPRYKER_PROJECT_NAME}-${app}:${tag}" &
        docker push "${ecr_base}/${SPRYKER_PROJECT_NAME}-${app}:latest" &
    done

    if [ "${SPRYKER_PUSH_ASSETS_CACHE}" == "${TRUE}" ]; then
        local assetsLockHash=$(Assets::_packageLockHash)
        local builderAssetsHash="${ecr_base}/${SPRYKER_PROJECT_NAME}-builder_assets:${assetsLockHash}"
        echo "${builderAssetsHash}"
        docker push "${builderAssetsHash}" &
    fi

    if [ "${SPRYKER_PUSH_COMPOSER_CACHE}" == "${TRUE}" ]; then
        local composerLockHash=$(Images::_composerLockHash)
        local composerCacheHash="${ecr_base}/${SPRYKER_PROJECT_NAME}-composer_cache:${composerLockHash}"
        echo "${composerCacheHash}"
        docker push "${composerCacheHash}" &
    fi

    wait
}
