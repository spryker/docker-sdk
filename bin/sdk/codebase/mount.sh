#!/bin/bash

function Codebase::build() {
    Console::verbose "${INFO}Building codebase${NC}"

    Compose::ensureCliRunning

    Compose::exec 'chmod 600 /data/config/Zed/*.key' || true

	# For avoid https://github.com/docker/compose/issues/9104
    local vendorDirExist=$(Compose::exec '[ ! -f /data/vendor/bin/install ] && echo 0 || echo 1 | tail -n 1' "${DOCKER_COMPOSE_TTY_DISABLED}"| tr -d " \n\r")
    if [ "$1" = "--force" ] || [ "${vendorDirExist}" == "0" ]; then
        Console::verbose "${INFO}Running composer install${NC}"
        # Compose::exec "composer clear-cache"
        Compose::exec "composer install --no-interaction ${SPRYKER_COMPOSER_MODE}"
        Compose::exec "composer dump-autoload ${SPRYKER_COMPOSER_AUTOLOAD}"
    fi

    Compose::exec 'chmod +x vendor/bin/*' || true

	# For avoid https://github.com/docker/compose/issues/9104
    local generatedDir=$(Compose::exec '[ ! -d /data/src/Generated ] && echo 0 || echo 1 | tail -n 1' "${DOCKER_COMPOSE_TTY_DISABLED}"| tr -d " \n\r")
    if [ "$1" = "--force" ] || [ "${generatedDir}" == "0" ]; then
        Console::verbose "${INFO}Running build${NC}"
        Compose::exec "vendor/bin/install -r ${SPRYKER_PIPELINE} -s build -s build-development"
    fi
}
