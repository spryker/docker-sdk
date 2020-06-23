#!/bin/bash

require docker docker-compose tr awk wc sed grep

Registry::Flow::addBoot "Compose::verboseMode"

function Compose::getComposeFiles() {
    local composeFiles="-f ${DEPLOYMENT_PATH}/docker-compose.yml"

    if [ "${SPRYKER_TESTING_ENABLE}" -eq 1 ]; then
        composeFiles+=" -f ${DEPLOYMENT_PATH}/docker-compose.test.yml"
    fi

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
    local isCliRunning=$(docker ps --filter 'status=running' --filter "name=${SPRYKER_DOCKER_PREFIX}_cli_*" --format "{{.Names}}")
    if [ -z "${isCliRunning}" ]; then
        Compose::run
    fi
}

function Compose::ensureCliRunning() {
    local isCliRunning=$(docker ps --filter 'status=running' --filter "name=${SPRYKER_DOCKER_PREFIX}_cli_*" --format "{{.Names}}")
    if [ -z "${isCliRunning}" ]; then
        Compose::run --no-deps cli
    fi
}

# ---------------
function Compose::exec() {
    local tty
    [ -t -0 ] && tty='' || tty='-T'

    Compose::command exec ${tty} \
        -e COMMAND="${*}" \
        -e APPLICATION_STORE="${SPRYKER_CURRENT_STORE}" \
        -e SPRYKER_CURRENT_REGION="${SPRYKER_CURRENT_REGION}" \
        -e SPRYKER_PIPELINE="${SPRYKER_PIPELINE}" \
        -e SPRYKER_XDEBUG_ENABLE_FOR_CLI="${SPRYKER_XDEBUG_ENABLE_FOR_CLI}" \
        -e SPRYKER_TESTING_ENABLE_FOR_CLI="$([ "${SPRYKER_TESTING_ENABLE}" -eq 1 ] && echo '1' || echo '')" \
        -e COMPOSER_AUTH="${COMPOSER_AUTH}" \
        cli \
        bash -c 'bash ~/bin/cli.sh'
}

function Compose::verboseMode() {
    local output=''
    if [ "${SPRYKER_FILE_MODE}" == 'mount' ]; then
        output+="  DEVELOPMENT MODE  "
    fi
    if [ "${SPRYKER_TESTING_ENABLE}" -eq 1 ]; then
        output+="  TESTING MODE  "
    fi
    if [ -n "${SPRYKER_XDEBUG_ENABLE_FOR_CLI}" ]; then
        output+="  DEBUGGING MODE  "
    fi
    if [ -n "${output}" ]; then
        Console::warn "-->${output}"
    fi
}

function Compose::command() {

    local -a composeFiles=()
    IFS=' ' read -r -a composeFiles <<< "$(Compose::getComposeFiles)"

    docker-compose \
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

    Images::build ${noCache} ${doBuild}
    Codebase::build ${noCache} ${doBuild}
    Assets::build ${noCache} ${doAssets}
    Compose::run --build
    Compose::command restart frontend rpc_server
    Data::load ${noCache} ${doData}
    Service::Scheduler::start ${noCache} ${doJobs}
}

function Compose::run() {
    Registry::Flow::runBeforeRun

    Console::verbose "${INFO}Running Spryker containers${NC}"
    Assets::init
    sync start
    Compose::command up -d --remove-orphans "${@}"
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
}

function Compose::down() {
    Console::verbose "${INFO}Stopping and removing all containers${NC}"
    Compose::command down --remove-orphans
    sync stop
}

function Compose::cleanVolumes() {
    Console::verbose "${INFO}Stopping and removing all Spryker containers and volumes${NC}"
    Compose::command down -v --remove-orphans
}

function Compose::cleanEverything() {
    Console::verbose "${INFO}Stopping and removing all Spryker containers and volumes${NC}"
    Compose::command down -v --remove-orphans --rmi all
}
