#!/usr/bin/env bash

import sdk/images/baked.sh

# -- portable file hash helper ------------------------------------------------

function Ecr2::_md5() {
    local file=${1}
    [ -f "${file}" ] || return 0
    if command -v md5sum >/dev/null 2>&1; then
        md5sum "${file}" | cut -d' ' -f1
        return 0
    fi
    if command -v md5 >/dev/null 2>&1; then
        md5 -q "${file}"
        return 0
    fi
    return 0
}

function Assets::_packageLockHash() {
    Ecr2::_md5 package-lock.json
}

function Images::_composerLockHash() {
    Ecr2::_md5 composer.lock
}

# -- ECR helpers --------------------------------------------------------------

function Ecr2::_ecrBase() {
    echo "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
}

function Ecr2::_assertAwsContext() {
    if [ -z "${AWS_ACCOUNT_ID}" ] || [ -z "${AWS_REGION}" ] || [ -z "${SPRYKER_PROJECT_NAME}" ]; then
        Console::verbose "${INFO}ECR cache: AWS_ACCOUNT_ID/AWS_REGION/SPRYKER_PROJECT_NAME unset, skipping${NC}" 1>&2
        return "${FALSE}"
    fi
    if ! command -v aws >/dev/null 2>&1; then
        Console::verbose "${WARN}ECR cache: aws CLI not found, skipping${NC}" 1>&2
        return "${FALSE}"
    fi
    return "${TRUE}"
}

function Ecr2::_ecrImageExists() {
    local repository=${1}
    local imageTag=${2}
    aws ecr describe-images \
        --repository-name "${repository}" \
        --image-ids "imageTag=${imageTag}" \
        --region "${AWS_REGION}" \
        >/dev/null 2>&1
}

# -- pull pre-built builder_assets from ECR by package-lock.json hash ---------

function Assets::_pullFromEcr() {
    local builderAssetsImage; builderAssetsImage=$(Assets::getImageTag)
    local lockHash; lockHash=$(Assets::_packageLockHash)
    [ -z "${lockHash}" ] && return "${FALSE}"

    local hashImage; hashImage="$(Ecr2::_ecrBase)/${SPRYKER_PROJECT_NAME}-builder_assets:${lockHash}"
    local currentHash="${SPRYKER_BUILD_HASH:-current}"

    Console::start "Trying builder_assets:${lockHash}..."

    if ! docker image inspect "${hashImage}" >/dev/null 2>&1 \
        && ! docker pull "${hashImage}" >/dev/null 2>&1; then
        Console::end "[NOT FOUND]"
        return "${FALSE}"
    fi

    # Re-tag the cached assets under the local builder_assets name and rewrite
    # the build-hash directory under /data/public/Yves/assets so the assets are
    # served at the URL prefix expected by the current SPRYKER_BUILD_HASH.
    if docker build -t "${builderAssetsImage}" - >/dev/null 2>&1 <<EOF
FROM busybox
COPY --from=${hashImage} /data/public /data/public
RUN cd /data/public/Yves/assets && \\
    for dir in */; do \\
        [ -d "\${dir}" ] && [ "\${dir%/}" != '${currentHash}' ] && mv "\${dir%/}" '${currentHash}' && break; \\
    done; true
EOF
    then
        Console::end "[FOUND]"
        return "${TRUE}"
    fi

    Console::end "[BUILD FAILED]"
    return "${FALSE}"
}

# -- override Assets::areBuilt: only consult ECR; skip the local check --------

function Assets::areBuilt() {
    Ecr2::_assertAwsContext || return "${FALSE}"
    Assets::_pullFromEcr
}

# -- composer cache: pull existing image to seed local BuildKit cache ---------

function Ecr2::_pullComposerCache() {
    local lockHash; lockHash=$(Images::_composerLockHash)
    [ -z "${lockHash}" ] && return "${FALSE}"

    local hashImage; hashImage="$(Ecr2::_ecrBase)/${SPRYKER_PROJECT_NAME}-composer_cache:${lockHash}"

    Console::start "Pulling composer cache from ECR (${lockHash})..."
    if docker pull "${hashImage}" >/dev/null 2>&1; then
        export SPRYKER_COMPOSER_CACHE_IMAGE="${hashImage}"
        Console::end "[FOUND]"
        return "${TRUE}"
    fi
    Console::end "[NOT FOUND]"
    return "${FALSE}"
}

# -- build a "minimal" builder_assets snapshot (only /data/public) ------------

function Ecr2::_buildMinimalAssetsImage() {
    local minimalImage=${1}
    local sourceImage; sourceImage="$(Assets::getImageTag)"

    docker image inspect "${minimalImage}" >/dev/null 2>&1 && return "${TRUE}"

    Console::verbose "${INFO}Creating minimal builder_assets image (only /data/public)${NC}"
    docker build -t "${minimalImage}" - >/dev/null 2>&1 <<EOF
FROM scratch
COPY --from=${sourceImage} /data/public /data/public
EOF
}

# -- tag minimal assets image with package-lock.json hash for cache push ------

function Ecr2::_tagAssetsCacheImage() {
    local minimalImage=${1}
    local lockHash; lockHash=$(Assets::_packageLockHash)
    [ -z "${lockHash}" ] && return "${FALSE}"

    local repository="${SPRYKER_PROJECT_NAME}-builder_assets"
    if Ecr2::_ecrImageExists "${repository}" "${lockHash}"; then
        Console::verbose "${INFO}Assets cache already exists for ${lockHash} [SKIP]${NC}"
        return "${TRUE}"
    fi

    docker tag "${minimalImage}" "$(Ecr2::_ecrBase)/${repository}:${lockHash}"
    export SPRYKER_PUSH_ASSETS_CACHE="${TRUE}"
    Console::verbose "${INFO}Assets cache tagged: ${lockHash} [NEW]${NC}"
}

# -- build composer cache image from BuildKit cache mount ---------------------
# uid=1000 matches the spryker user contract used in images/baked/application/Dockerfile.

function Ecr2::_buildComposerCacheImage() {
    local lockHash; lockHash=$(Images::_composerLockHash)
    [ -z "${lockHash}" ] && return "${FALSE}"

    local repository="${SPRYKER_PROJECT_NAME}-composer_cache"
    if Ecr2::_ecrImageExists "${repository}" "${lockHash}"; then
        Console::verbose "${INFO}Composer cache already exists for ${lockHash} [SKIP]${NC}"
        return "${TRUE}"
    fi

    local cacheImage; cacheImage="$(Ecr2::_ecrBase)/${repository}:${lockHash}"

    Console::start "Creating composer cache image (${lockHash})..."
    if docker build -t "${cacheImage}" - >/dev/null <<EOF
# syntax = docker/dockerfile:experimental
FROM ${SPRYKER_PLATFORM_IMAGE} AS export
RUN --mount=type=cache,id=composer,sharing=locked,target=/composer-cache,uid=1000 \\
    mkdir -p /export/cache && cp -a /composer-cache/. /export/cache/ 2>/dev/null || true

FROM scratch
COPY --from=export /export /
EOF
    then
        export SPRYKER_PUSH_COMPOSER_CACHE="${TRUE}"
        Console::end "[NEW]"
    else
        Console::end "[SKIPPED]"
    fi
}

# -- public API ---------------------------------------------------------------

function Images::buildApplication() {
    Console::verbose "${INFO}Building application images for AWS ECR${NC}"

    # Reset state from any previous invocation in the same shell.
    unset SPRYKER_COMPOSER_CACHE_IMAGE SPRYKER_PUSH_ASSETS_CACHE SPRYKER_PUSH_COMPOSER_CACHE

    if Ecr2::_assertAwsContext; then
        Ecr2::_pullComposerCache || true
    fi

    Images::_buildApp baked "${TRUE}" "${TRUE}"
}

function Images::buildFrontend() {
    Console::verbose "${INFO}Building Frontend image for AWS ECR${NC}"

    Images::_buildFrontend baked
    Images::_buildGateway
}

function Images::tagApplications() {
    local tag=${1:-${SPRYKER_DOCKER_TAG}}
    local ecr_base; ecr_base="$(Ecr2::_ecrBase)"

    Console::verbose "${INFO}Tag images for AWS ECR${NC}"
    for application in "${SPRYKER_APPLICATIONS[@]}"; do
        application="$(echo "${application}" | tr '[:upper:]' '[:lower:]')"
        docker tag "${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}" "${ecr_base}/${SPRYKER_PROJECT_NAME}-${application}:${tag}"
        docker tag "${SPRYKER_DOCKER_PREFIX}_app:${SPRYKER_DOCKER_TAG}" "${ecr_base}/${SPRYKER_PROJECT_NAME}-${application}:latest"
    done

    docker tag "${SPRYKER_DOCKER_PREFIX}_jenkins:${SPRYKER_DOCKER_TAG}" "${ecr_base}/${SPRYKER_PROJECT_NAME}-jenkins:${tag}"
    docker tag "${SPRYKER_DOCKER_PREFIX}_jenkins:${SPRYKER_DOCKER_TAG}" "${ecr_base}/${SPRYKER_PROJECT_NAME}-jenkins:latest"
}

function Images::tagFrontend() {
    Console::verbose "${INFO}Tagging Frontend for AWS ECR${NC}"

    local tag=${1:-${SPRYKER_DOCKER_TAG}}
    local ecr_base; ecr_base="$(Ecr2::_ecrBase)"

    docker tag "${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}" "${ecr_base}/${SPRYKER_PROJECT_NAME}-frontend:${tag}"
    docker tag "${SPRYKER_DOCKER_PREFIX}_frontend:${SPRYKER_DOCKER_TAG}" "${ecr_base}/${SPRYKER_PROJECT_NAME}-frontend:latest"

    Ecr2::_assertAwsContext || return "${TRUE}"

    local minimalImage="${SPRYKER_DOCKER_PREFIX}_builder_assets_minimal:${SPRYKER_DOCKER_TAG}"
    Ecr2::_buildMinimalAssetsImage "${minimalImage}"
    Ecr2::_tagAssetsCacheImage "${minimalImage}"
    Ecr2::_buildComposerCacheImage
}

function Images::push() {
    Console::verbose "${INFO}Pushing images to AWS ECR${NC}"
    local tag=${1:-${SPRYKER_DOCKER_TAG}}
    local ecr_base; ecr_base="$(Ecr2::_ecrBase)"
    local pids=() rc=0 image

    local apps=(boffice frontend jenkins)
    for app in "${apps[@]}"; do
        for image in \
            "${ecr_base}/${SPRYKER_PROJECT_NAME}-${app}:${tag}" \
            "${ecr_base}/${SPRYKER_PROJECT_NAME}-${app}:latest"; do
            echo "${image}"
            docker push "${image}" & pids+=($!)
        done
    done

    if [ "${SPRYKER_PUSH_ASSETS_CACHE}" == "${TRUE}" ]; then
        local lockHash; lockHash=$(Assets::_packageLockHash)
        image="${ecr_base}/${SPRYKER_PROJECT_NAME}-builder_assets:${lockHash}"
        echo "${image}"
        docker push "${image}" & pids+=($!)
    fi

    if [ "${SPRYKER_PUSH_COMPOSER_CACHE}" == "${TRUE}" ]; then
        local lockHash; lockHash=$(Images::_composerLockHash)
        image="${ecr_base}/${SPRYKER_PROJECT_NAME}-composer_cache:${lockHash}"
        echo "${image}"
        docker push "${image}" & pids+=($!)
    fi

    for p in "${pids[@]}"; do
        wait "${p}" || rc=1
    done
    return "${rc}"
}
