#!/bin/bash

# shellcheck disable=SC2155

require docker docker-compose tr awk wc sed grep

Registry::Flow::addBoot "Compose::verboseMode"

function Compose::getComposeFiles() {
    local composeFiles="-f ${DEPLOYMENT_PATH}/docker-compose.yml"

    for composeFile in ${DOCKER_COMPOSE_FILES_EXTRA}; do
        composeFiles+=" -f ${composeFile}"
    done

    echo "${composeFiles}"
}

function Compose::ensureTestingMode() {
    SPRYKER_TESTING_ENABLE=1
    local isTestMode=$(docker ps --filter 'status=running' --filter "name=${SPRYKER_DOCKER_PREFIX}_webdriver_*" --format "{{.Names}}")
    if [ -z "${isTestMode}" ]; then
        Compose::run
    fi
}

function Compose::ensureRunning() {
    local service=${1:-'cli'}
    local isCliRunning=$(docker ps --filter 'status=running' --filter "name=${SPRYKER_DOCKER_PREFIX}_${service}_*" --format "{{.Names}}")
    if [ -z "${isCliRunning}" ]; then
        Compose::run
    fi
}

function Compose::ensureCliRunning() {
    local isCliRunning=$(docker ps --filter 'status=running' --filter "ancestor=${SPRYKER_DOCKER_PREFIX}_run_cli:${SPRYKER_DOCKER_TAG}" --filter "name=${SPRYKER_DOCKER_PREFIX}_cli_*" --format "{{.Names}}")
    if [ -z "${isCliRunning}" ]; then
        Compose::run --no-deps cli cli_ssh_relay
        Registry::Flow::runAfterCliReady
    fi
}

# ---------------
function Compose::exec() {
    local tty
    [ -t -0 ] && tty='' || tty='-T'

	# For avoid https://github.com/docker/compose/issues/9104
	local ttyDisabledKey='docker_compose_tty_disabled'
	local lastArg="${@: -1}"
	if [ "${DOCKER_COMPOSE_TTY_DISABLED}" = "${lastArg}" ]; then
		if  [ "${DOCKER_COMPOSE_TTY_DISABLED}" = "${ttyDisabledKey}" ]; then
			tty='-T'
		fi

		set -- "${@:1:$(($#-1))}"
	fi

    Compose::command exec ${tty} \
        -e COMMAND="${*}" \
        -e APPLICATION_STORE="${SPRYKER_CURRENT_STORE}" \
        -e SPRYKER_CURRENT_REGION="${SPRYKER_CURRENT_REGION}" \
        -e SPRYKER_PIPELINE="${SPRYKER_PIPELINE}" \
        -e SSH_AUTH_SOCK="${SSH_AUTH_SOCK_IN_CLI}" \
        -e SPRYKER_XDEBUG_MODE_ENABLE="${SPRYKER_XDEBUG_MODE_ENABLE}" \
        -e SPRYKER_XDEBUG_ENABLE_FOR_CLI="${SPRYKER_XDEBUG_ENABLE_FOR_CLI}" \
        -e SPRYKER_TESTING_ENABLE_FOR_CLI="${SPRYKER_TESTING_ENABLE_FOR_CLI}" \
        -e COMPOSER_AUTH="${COMPOSER_AUTH}" \
        cli \
        bash -c 'bash ~/bin/cli.sh'
}

function Compose::verboseMode() {
    local output=''
    if [ "${SPRYKER_FILE_MODE}" == 'mount' ]; then
        output+="  DEVELOPMENT MODE  "
    fi
    if [ -n "${SPRYKER_TESTING_ENABLE}" ]; then
        output+="  TESTING MODE  "
    fi
    if [ -n "${SPRYKER_XDEBUG_ENABLE}" ] && [ -n "${SPRYKER_XDEBUG_MODE_ENABLE}" ]; then
        output+="  DEBUGGING MODE  "
    fi
    if [ -n "${output}" ]; then
        Console::warn "-->${output}"
    fi
    if [ -n "${SPRYKER_XDEBUG_ENABLE}" ] && [ -z "${SPRYKER_XDEBUG_MODE_ENABLE}" ]; then
        Console::error "Debugging is disabled in deploy.yml. Please, set ${INFO}deploy.yml: docker: debug: xdebug: enabled: true${WARN}, bootstrap and up to start debugging."
    fi
}

function Compose::command() {

    local -a composeFiles=()
    IFS=' ' read -r -a composeFiles <<< "$(Compose::getComposeFiles)"

    ${DOCKER_COMPOSE_SUBSTITUTE:-'docker-compose'} \
        --project-directory "${PROJECT_DIR}" \
        --project-name "${SPRYKER_DOCKER_PREFIX}" \
        "${composeFiles[@]}" \
        "${@}"
}

# ---------------
function Compose::up() {

    local noCache=""
    local doBuild=""
    local doAssets=""
    local doData=""
    local doJobs=""

    for arg in "${@}"; do
        case "${arg}" in
            '--build')
                doBuild="--force"
                ;;
            '--assets')
                doAssets="--force"
                ;;
            '--data')
                doData="--force"
                ;;
            '--jobs')
                doJobs="--force"
                ;;
            '--no-cache')
                # TODO --no-cache flag. Ticket is necessary
                noCache="--no-cache"
                ;;
            *)
                Console::verbose "\nUnknown option ${INFO}${arg}${WARN} is acquired."
                ;;
        esac
    done

    Registry::Flow::runBeforeUp

    Images::buildApplication ${noCache} ${doBuild}
    Codebase::build ${noCache} ${doBuild}
    Assets::build ${noCache} ${doAssets}
    Images::buildFrontend ${noCache} ${doBuild}
    Compose::run --build
    Compose::command restart frontend gateway

    Registry::Flow::runAfterUp

    Data::load ${noCache} ${doData}
    Service::Scheduler::start ${noCache} ${doJobs}
}

function Compose::run() {

    Registry::Flow::runBeforeRun

    Console::verbose "${INFO}Running Spryker containers${NC}"
    sync start

    Compose::command --compatibility up -d --remove-orphans --quiet-pull "${@}"

    if [ -n "${SPRYKER_TESTING_ENABLE}" ]; then
        Compose::command --compatibility stop scheduler
    fi

    if [ -z "${SPRYKER_TESTING_ENABLE}" ]; then
        Compose::command --compatibility stop webdriver
    fi

    # Note: Compose::run can be used for running only one container, e.g. CLI.
    Registry::Flow::runAfterRun
}

function Compose::ps() {
    Compose::command ps "${@}"
}

function Compose::restart() {
    Console::verbose "${INFO}Restarting Spryker containers${NC}"
    Compose::stop
    Compose::run
}

function Compose::stop() {
    Console::verbose "${INFO}Stopping all containers${NC}"
    Compose::command stop
    Registry::Flow::runAfterStop
}

function Compose::down() {
    Console::verbose "${INFO}Stopping and removing all containers${NC}"
    Compose::command down --remove-orphans
    sync stop
    Registry::Flow::runAfterDown
}

function Compose::cleanVolumes() {
    Console::verbose "${INFO}Stopping and removing all Spryker containers and volumes${NC}"
    Compose::command down -v --remove-orphans
    Registry::Flow::runAfterDown
}

function Compose::cleanEverything() {
    Console::verbose "${INFO}Stopping and removing all Spryker containers and volumes${NC}"
    Compose::command down -v --remove-orphans --rmi all
    Registry::Flow::runAfterDown
}
