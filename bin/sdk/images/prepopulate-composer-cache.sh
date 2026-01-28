#!/usr/bin/env bash

# Pre-populate Docker BuildKit composer cache from host composer cache
# This speeds up Docker builds by copying existing composer packages into Docker's cache mount

set -e

# Check if composer is installed
if ! command -v composer &> /dev/null; then
    echo "Warning: composer command not found. Skipping cache pre-population."
    exit 0
fi

COMPOSER_CACHE_DIR=$(composer config cache-dir)

if [ -z "$(ls -A "${COMPOSER_CACHE_DIR}" 2>/dev/null | grep -v '^\.htaccess$')" ]; then
    echo "Warning: Composer cache directory ${COMPOSER_CACHE_DIR} is empty (excluding .htaccess). Skipping pre-population."
    exit 0
fi

echo "Pre-populating Docker BuildKit cache from ${COMPOSER_CACHE_DIR}"

# Create a temporary directory for the build context
TEMP_CONTEXT=$(mktemp -d)
trap "rm -rf ${TEMP_CONTEXT}" EXIT

# Copy composer cache to temporary context
echo "Copying cache to temporary context..."
mkdir -p "${TEMP_CONTEXT}/cache"
cp -a "${COMPOSER_CACHE_DIR}/." "${TEMP_CONTEXT}/cache/" 2>/dev/null || true

# Create a temporary Dockerfile to copy cache into Docker's cache mount
# Using the same cache id and target path as the main Dockerfile
cat > "${TEMP_CONTEXT}/Dockerfile" <<'EOF'
FROM alpine:latest
RUN adduser -u 1000 -D spryker
USER spryker
COPY --chown=spryker:spryker cache /cache-source
RUN --mount=type=cache,id=composer,sharing=locked,target=/home/spryker/.composer/cache,uid=1000 \
    if [ -n "$(ls -A /cache-source 2>/dev/null)" ]; then \
        echo "Copying composer cache to Docker cache mount..."; \
        cp -a /cache-source/. /home/spryker/.composer/cache/ 2>/dev/null || true; \
        echo "Cache pre-population complete. Cache directory size:"; \
        du -sh /home/spryker/.composer/cache 2>/dev/null || echo "Cache populated"; \
    else \
        echo "No files to copy from source cache"; \
    fi
EOF

# Build the temporary image to populate the cache
DOCKER_BUILDKIT=1 docker build \
    -f "${TEMP_CONTEXT}/Dockerfile" \
    "${TEMP_CONTEXT}"

echo "Docker BuildKit composer cache pre-populated successfully!"
