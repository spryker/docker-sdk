#!/usr/bin/env bash

# Pre-populate Docker BuildKit composer cache from host composer cache
# This speeds up Docker builds by copying existing composer packages into Docker's cache mount

set -e

COMPOSER_CACHE_DIR=$(composer config cache-dir)

echo "Pre-populating Docker BuildKit cache from ${COMPOSER_CACHE_DIR}"

if [ ! -d "${COMPOSER_CACHE_DIR}" ]; then
    echo "Warning: Composer cache directory ${COMPOSER_CACHE_DIR} does not exist. Skipping pre-population."
    exit 0
fi

# Create a temporary Dockerfile to copy cache into Docker's cache mount
cat > /tmp/prepopulate-cache.Dockerfile <<'EOF'
FROM alpine:latest
ARG COMPOSER_CACHE_DIR
RUN --mount=type=cache,id=composer,sharing=locked,target=/cache \
    if [ -n "$(ls -A /source 2>/dev/null)" ]; then \
        echo "Copying composer cache to Docker cache mount..."; \
        cp -a /source/. /cache/ || true; \
        echo "Cache pre-population complete. Files in cache:"; \
        ls -lah /cache | head -20; \
    else \
        echo "No files to copy from source cache"; \
    fi
EOF

# Build the temporary image to populate the cache
DOCKER_BUILDKIT=1 docker build \
    --build-arg COMPOSER_CACHE_DIR="${COMPOSER_CACHE_DIR}" \
    --mount type=bind,source="${COMPOSER_CACHE_DIR}",target=/source \
    -f /tmp/prepopulate-cache.Dockerfile \
    /tmp

rm -f /tmp/prepopulate-cache.Dockerfile

echo "Docker BuildKit composer cache pre-populated successfully!"

