#!/bin/bash
set -e

# 1. PHP Extensions (replaces Twig-templated mv in Dockerfile.twig)
#    Expects comma-separated list: SPRYKER_PHP_EXTENSIONS=otel,amqp,blackfire
if [ -n "${SPRYKER_PHP_EXTENSIONS}" ]; then
    IFS=',' read -ra EXTENSIONS <<< "${SPRYKER_PHP_EXTENSIONS}"
    for ext in "${EXTENSIONS[@]}"; do
        ext=$(echo "$ext" | xargs)
        src="/usr/local/etc/php/disabled/${ext}.ini"
        dst="/usr/local/etc/php/conf.d/90-${ext}.ini"
        if [ -f "$src" ] && [ ! -f "$dst" ]; then
            cp "$src" "$dst"
        fi
    done
fi

# 2. User UID matching (replaces usermod in mount/application/Dockerfile)
if [ -n "${SPRYKER_USER_UID}" ] && [ "$(id -u spryker)" != "${SPRYKER_USER_UID}" ]; then
    usermod -u "${SPRYKER_USER_UID}" spryker
    chown -R spryker:spryker /home/spryker /tmp/spryker 2>/dev/null || true
fi

# 3. SSL CA trust (replaces application-local/Dockerfile)
if ls /usr/local/share/ca-certificates/*.crt 1>/dev/null 2>&1; then
    update-ca-certificates 2>/dev/null || true
fi

# 4. Log directory
if [ -n "${SPRYKER_LOG_DIRECTORY}" ]; then
    mkdir -p "${SPRYKER_LOG_DIRECTORY}" 2>/dev/null || true
    chown spryker:spryker "${SPRYKER_LOG_DIRECTORY}" 2>/dev/null || true
fi

# 5. Known hosts
if [ -n "${KNOWN_HOSTS}" ]; then
    ssh-keyscan -t rsa ${KNOWN_HOSTS} >> /home/spryker/.ssh/known_hosts 2>/dev/null || true
    chown spryker:spryker /home/spryker/.ssh/known_hosts 2>/dev/null || true
fi

# Drop to spryker user and exec CMD
exec gosu spryker "$@"
