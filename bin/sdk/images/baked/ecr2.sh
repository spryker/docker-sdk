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

function Assets::isCacheEnabled() {
    case "${SPRYKER_ASSETS_CACHE}" in
        0 | false) return "${FALSE}" ;;
    esac
    return "${TRUE}"
}

# Expands assets.cache.paths entries (wildcards allowed) to existing paths; warns about entries matching nothing.
function Assets::_cachePathInputs() {
    local IFS=$'\n'
    local entry match found
    for entry in "${SPRYKER_ASSETS_CACHE_PATHS[@]}"; do
        found=0
        for match in ${entry}; do
            if [ -e "${match}" ]; then
                echo "${match}"
                found=1
            fi
        done
        if [ "${found}" = 0 ]; then
            Console::warn "Assets cache path \"${entry}\" matches no file or directory, so it is not watched." >&2
        fi
    done
    return 0
}

# Hash of every input the assets build reads, so a change in any of them produces a new key.
function Assets::_computeCacheKey() {
    [ -f package-lock.json ] || return 0

    # Bump to invalidate every cached builder_assets image after a key format change.
    local keyVersion=v2

    local -a md5Cmd=(md5sum)
    command -v md5sum >/dev/null 2>&1 || md5Cmd=(md5 -r)

    local -a inputs=()
    local input
    for input in package.json package-lock.json composer.lock .npmrc .browserslistrc nx.json project.json tsconfig*.json \
        frontend config/Yves config/install; do
        if [ -e "${input}" ]; then
            inputs+=("${input}")
        fi
    done
    while IFS= read -r input; do
        if [ -n "${input}" ]; then
            inputs+=("${input}")
        fi
    done <<< "$(Assets::_cachePathInputs)"

    {
        echo "${keyVersion} ${SPRYKER_ASSETS_MODE} ${SPRYKER_PIPELINE} ${SPRYKER_PLATFORM_IMAGE}" \
            "${SPRYKER_NODE_IMAGE_VERSION} ${SPRYKER_NODE_IMAGE_DISTRO} ${SPRYKER_NPM_VERSION}"
        {
            find "${inputs[@]}" -type f -not -path '*/node_modules/*' -print0
            if [ -d src ]; then
                find src -type f -not -path '*/node_modules/*' \
                    \( -path '*/Theme/*' -o -path '*/assets/*' -o -path '*/Presentation/Components/*' \) -print0
            fi
        } 2>/dev/null | LC_ALL=C sort -z | xargs -0 ${XARGS_NO_RUN_IF_EMPTY} "${md5Cmd[@]}"
    } | "${md5Cmd[@]}" | cut -d' ' -f1

    return 0
}

function Assets::_cacheKey() {
    if [ -n "${SPRYKER_ASSETS_CACHE_KEY}" ]; then
        echo "${SPRYKER_ASSETS_CACHE_KEY}"
        return 0
    fi
    Assets::_computeCacheKey
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

# -- pull pre-built builder_assets from ECR by assets cache key ---------------

function Assets::_pullFromEcr() {
    local builderAssetsImage; builderAssetsImage=$(Assets::getImageTag)
    local cacheKey; cacheKey=$(Assets::_cacheKey)
    [ -z "${cacheKey}" ] && return "${FALSE}"

    local hashImage; hashImage="$(Ecr2::_ecrBase)/${SPRYKER_PROJECT_NAME}-builder_assets:${cacheKey}"
    local currentHash="${SPRYKER_BUILD_HASH:-current}"

    Console::start "Trying builder_assets:${cacheKey}..."

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
    Assets::isCacheEnabled || return "${FALSE}"
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

# -- tag minimal assets image with assets cache key for cache push ------------

function Ecr2::_tagAssetsCacheImage() {
    local minimalImage=${1}
    local cacheKey; cacheKey=$(Assets::_cacheKey)
    [ -z "${cacheKey}" ] && return "${FALSE}"

    local repository="${SPRYKER_PROJECT_NAME}-builder_assets"
    if Ecr2::_ecrImageExists "${repository}" "${cacheKey}"; then
        Console::verbose "${INFO}Assets cache already exists for ${cacheKey} [SKIP]${NC}"
        return "${TRUE}"
    fi

    docker tag "${minimalImage}" "$(Ecr2::_ecrBase)/${repository}:${cacheKey}"
    export SPRYKER_PUSH_ASSETS_CACHE="${TRUE}"
    Console::verbose "${INFO}Assets cache tagged: ${cacheKey} [NEW]${NC}"
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
    unset SPRYKER_COMPOSER_CACHE_IMAGE SPRYKER_PUSH_ASSETS_CACHE SPRYKER_PUSH_COMPOSER_CACHE SPRYKER_ASSETS_CACHE_KEY

    if Assets::isCacheEnabled; then
        SPRYKER_ASSETS_CACHE_KEY="$(Assets::_computeCacheKey)"
        export SPRYKER_ASSETS_CACHE_KEY
    else
        Console::log "${INFO}Assets cache is disabled, assets will be rebuilt${NC}"
    fi

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

    if Assets::isCacheEnabled; then
        local minimalImage="${SPRYKER_DOCKER_PREFIX}_builder_assets_minimal:${SPRYKER_DOCKER_TAG}"
        Ecr2::_buildMinimalAssetsImage "${minimalImage}"
        Ecr2::_tagAssetsCacheImage "${minimalImage}"
    fi
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
        local cacheKey; cacheKey=$(Assets::_cacheKey)
        image="${ecr_base}/${SPRYKER_PROJECT_NAME}-builder_assets:${cacheKey}"
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
