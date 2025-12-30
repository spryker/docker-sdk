#!/usr/bin/env bash

require docker grep awk

import lib/version.sh
import lib/string.sh

import environment/docker-compose.sh

# shellcheck disable=SC2034

function Mount::Mutagen::sessionExists() {
    local sessionName="${1:-${SPRYKER_SYNC_SESSION_NAME}}"
    local count=$(mutagen sync list "${sessionName}" 2>/dev/null | grep -c 'Name:' 2>/dev/null | tr -d '\n' || echo '0')
    count=$(echo "${count}" | tr -d '[:space:]')
    [ "${count}" -gt 0 ] 2>/dev/null
}

function Mount::logs() {
    if ! Mount::Mutagen::sessionExists; then
        Console::error "Mutagen sync session '${SPRYKER_SYNC_SESSION_NAME}' does not exist."
        Console::error "Please ensure containers are running and the sync session has been created."
        Console::error "Try running: docker/sdk boot"
        return 1
    fi
    
    mutagen sync monitor "${SPRYKER_SYNC_SESSION_NAME}"
}

function sync() {
    local command="${1:-start}"
    local syncVolume="${SPRYKER_SYNC_VOLUME}"

    case "${command}" in
        create)
            Console::verbose "${INFO}Creating 'data-sync' volume${NC}"
            docker volume create --name="${syncVolume}" >/dev/null 2>&1 || true
            ;;
        recreate)
            sync clean
            sync create
            ;;
        clean)
            if Mount::Mutagen::sessionExists; then
                mutagen sync terminate "${SPRYKER_SYNC_SESSION_NAME}" >/dev/null 2>&1 || true
            fi
            docker volume rm "${syncVolume}" >/dev/null 2>&1 || true
            ;;
        stop)
            if Mount::Mutagen::sessionExists; then
                Console::verbose "${INFO}Pausing sync session${NC}"
                mutagen sync pause "${SPRYKER_SYNC_SESSION_NAME}" >/dev/null 2>&1 || true
            fi
            ;;
        start|'')
            Mount::Mutagen::ensureDaemonRunning
            
            if Mount::Mutagen::findAndResumePausedSession; then
                Console::verbose "${INFO}Mutagen sync session resumed${NC}"
                return 0
            fi
            
            if [ -n "${SPRYKER_SYNC_SESSION_NAME}" ] && Mount::Mutagen::sessionExists "${SPRYKER_SYNC_SESSION_NAME}"; then
                Console::verbose "${INFO}Mutagen sync session already exists${NC}"
                return 0
            fi
            
            local targetContainer=$(Mount::Mutagen::findTargetContainer)
            if [ -n "${targetContainer}" ]; then
                if Mount::Mutagen::createSyncSession; then
                    if Mount::Mutagen::sessionExists; then
                        Console::verbose "${INFO}Mutagen sync session created successfully${NC}"
                        return 0
                    fi
                fi
                # If creation failed, it will be retried in afterRun
                Console::verbose "${INFO}Sync session creation will be retried after containers are fully started${NC}"
            else
                Console::verbose "${INFO}Containers not running yet, sync session will be created when containers are ready${NC}"
            fi
            ;;
        logs|log)
            Mount::logs "${@}"
            ;;
        *)
            Console::error "Unknown sync command: ${command}"
            return 1
            ;;
    esac
}

function Mount::Mutagen::beforeUp() {
    local sessionStatus
    local containersRunning
    local targetContainer

    targetContainer=$(Mount::Mutagen::findTargetContainer)
    containersRunning=$([ -n "${targetContainer}" ] && echo "1" || echo "0")

    if [ "${containersRunning}" == "0" ]; then
        docker volume rm "${SPRYKER_SYNC_VOLUME}" >/dev/null 2>&1 || true
    fi

    updateComposeCovertWindowsPaths

    if [ "${containersRunning}" == "0" ]; then
        terminateMutagenSessionsWithObsoleteDockerId
    else
        if Mount::Mutagen::sessionExists; then
            sessionStatus=$(mutagen sync list "${SPRYKER_SYNC_SESSION_NAME}" 2>/dev/null | grep 'Status:' | awk '{print $2}' | tr -d '[]' || echo '')
            if [ "${sessionStatus}" == 'Halted' ] || [ "${sessionStatus}" == 'Disconnected' ]; then
                Console::verbose "${INFO}Terminating unhealthy sync session (status: ${sessionStatus})${NC}"
                terminateMutagenSessionsWithObsoleteDockerId
            else
                Console::verbose "${INFO}Keeping existing sync session (status: ${sessionStatus})${NC}"
                return 0
            fi
        fi
    fi

    sessionStatus=$(mutagen sync list "${SPRYKER_SYNC_SESSION_NAME}" 2>/dev/null | grep 'Status:' | awk '{print $2}' | tr -d '[]' || echo '')
    if [ -z "${sessionStatus}" ] || [ "${sessionStatus}" == 'Halted' ]; then
        Console::verbose::start "${INFO}Cleaning previous synced files${NC}"
        mutagen sync terminate "${SPRYKER_SYNC_SESSION_NAME}" >/dev/null 2>&1 || true
        if [ "${containersRunning}" == "0" ]; then
            docker run -i --rm -v "${SPRYKER_SYNC_VOLUME}:/data" busybox find /data/ ! -path /data/ -delete >/dev/null 2>&1 || true
        fi
        Console::end "[OK]"
    fi
}

# https://github.com/docker/compose/issues/9428
function updateComposeCovertWindowsPaths() {
    local mutagenInstalledVersion="$(Mount::Mutagen::getInstalledVersion)"
	local installedVersion=$(Version::parse ${mutagenInstalledVersion})

    if [ "${installedVersion:0:2}" -ge 14 ]; then
        export COMPOSE_CONVERT_WINDOWS_PATHS=0
    fi
}

function terminateMutagenSessionsWithObsoleteDockerId() {
    if Mount::Mutagen::sessionExists; then
        Console::verbose "Terminating existing mutagen sync sessions"
        mutagen sync terminate "${SPRYKER_SYNC_SESSION_NAME}" >/dev/null 2>&1 || true
    fi
}

# This is necessary due to https://github.com/mutagen-io/mutagen/issues/224
function Mount::Mutagen::beforeRun() {
    Console::verbose::start "${INFO}Creating file syncronization volume${NC}"
    docker volume create --name="${SPRYKER_SYNC_VOLUME}" >/dev/null
    docker run -it --rm -v "${SPRYKER_SYNC_VOLUME}:/data" busybox chmod 777 /data >/dev/null 2>&1
    Console::end "[OK]"
}

function Mount::Mutagen::getTimeoutCmd() {
    if command -v timeout >/dev/null 2>&1; then
        echo "timeout"
    elif command -v gtimeout >/dev/null 2>&1; then
        echo "gtimeout"
    fi
}

function Mount::Mutagen::runWithTimeout() {
    local timeoutSeconds="${1}"
    shift
    local timeoutCmd=$(Mount::Mutagen::getTimeoutCmd)
    
    if [ -n "${timeoutCmd}" ]; then
        ${timeoutCmd} "${timeoutSeconds}" "$@"
    else
        "$@"
    fi
}

function Mount::Mutagen::ensureDaemonRunning() {
    if ! Mount::Mutagen::runWithTimeout 2 mutagen daemon list >/dev/null 2>&1; then
        Console::verbose "Starting Mutagen daemon..."
        mutagen daemon start >/dev/null 2>&1 || true
        sleep 1
    fi
    
    if ! Mount::Mutagen::runWithTimeout 2 mutagen sync list >/dev/null 2>&1; then
        mutagen daemon stop >/dev/null 2>&1 || true
        sleep 1
        mutagen daemon start >/dev/null 2>&1 || true
        sleep 1
    fi
}


function Mount::Mutagen::buildIgnoreArgs() {
    local deploymentDir="${DEPLOYMENT_PATH:-docker/deployment/default}"
    local ignoreFile="${deploymentDir}/.dockersyncignore"
    
    if [ ! -f "${ignoreFile}" ]; then
        ignoreFile=".dockersyncignore"
    fi
    
    local defaultIgnores=".git docker data/*/cache .docker-sync .idea .project *.log node_modules .composer .npm vendor .DS_Store"
    
    local ignorePatterns=""
    
    if [ -f "${ignoreFile}" ]; then
        while IFS= read -r line || [ -n "${line}" ]; do
            line=$(echo "${line}" | sed 's/#.*$//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            [ -z "${line}" ] && continue
            ignorePatterns="${ignorePatterns} ${line}"
        done < "${ignoreFile}"
    else
        ignorePatterns="${defaultIgnores}"
    fi
    
    local ignoreArgs=""
    for pattern in ${ignorePatterns}; do
        ignoreArgs="${ignoreArgs} --ignore=\"${pattern}\""
    done
    ignoreArgs="${ignoreArgs} --ignore-vcs"
    
    echo "${ignoreArgs}"
}

function Mount::Mutagen::findTargetContainer() {
    local volumeName="${SPRYKER_SYNC_VOLUME}"
    local targetContainer=$(docker ps --filter "name=${SPRYKER_DOCKER_PREFIX}_cli_" --filter "status=running" --format "{{.Names}}" | grep -v "ssh_relay" | head -n1)
    
    if [ -z "${targetContainer}" ]; then
        targetContainer=$(docker ps --filter "volume=${volumeName}" --filter "status=running" --format "{{.Names}}" | grep -v "ssh_relay" | head -n1)
    fi
    
    echo "${targetContainer}"
}

function Mount::Mutagen::createSyncSession() {
    Mount::Mutagen::ensureDaemonRunning
    
    if Mount::Mutagen::sessionExists; then
        Console::verbose "Mutagen sync session '${SPRYKER_SYNC_SESSION_NAME}' already exists."
        return 0
    fi
    
    Console::verbose::start "${INFO}Creating mutagen sync session${NC}"
    
    local projectPath="$(pwd)"
    local targetContainer=$(Mount::Mutagen::findTargetContainer)
    
    if [ -z "${targetContainer}" ]; then
        Console::error "No running container found with volume ${SPRYKER_SYNC_VOLUME}. Please ensure containers are running."
        Console::end "[FAILED]"
        return 1
    fi
    
    local containerPath="/data"
    local ignoreArgsStr=$(Mount::Mutagen::buildIgnoreArgs)
    local timeoutCmd=$(Mount::Mutagen::getTimeoutCmd)
    local createOutput
    
    if [ -n "${timeoutCmd}" ]; then
        createOutput=$(eval "${timeoutCmd} 30 mutagen sync create --name=\"${SPRYKER_SYNC_SESSION_NAME}\" --default-file-mode=0666 --default-directory-mode=0777 --symlink-mode=posix-raw ${ignoreArgsStr} \"${projectPath}\" \"docker://${targetContainer}${containerPath}\"" 2>&1)
    else
        Console::verbose "Warning: timeout command not available. Sync creation may hang if there are issues."
        createOutput=$(eval "mutagen sync create --name=\"${SPRYKER_SYNC_SESSION_NAME}\" --default-file-mode=0666 --default-directory-mode=0777 --symlink-mode=posix-raw ${ignoreArgsStr} \"${projectPath}\" \"docker://${targetContainer}${containerPath}\"" 2>&1)
    fi
    local createExitCode=$?
    
    if [ ${createExitCode} -eq 0 ]; then
        Console::end "[OK]"
    else
        Console::end "[FAILED]"
        if echo "${createOutput}" | grep -q "server magic number incorrect\|unable to handshake"; then
            if [ -z "${_MUTAGEN_VERSION_MISMATCH_SHOWN:-}" ]; then
                export _MUTAGEN_VERSION_MISMATCH_SHOWN=1
                Console::error "Mutagen daemon version mismatch detected."
                Console::error "Please restart the Mutagen daemon:"
                Console::error "  mutagen daemon stop && mutagen daemon start"
                Console::error ""
                Console::error "Or reinstall Mutagen:"
                Console::error "  brew list | grep mutagen | xargs brew remove && brew install mutagen-io/mutagen/mutagen && mutagen daemon stop && mutagen daemon start"
            fi
        else
            Console::error "Failed to create Mutagen sync session:"
            echo "${createOutput}" | sed 's/^/  /'
        fi
        return 1
    fi
}

# This is necessary due to https://github.com/mutagen-io/mutagen/issues/225
function Mount::Mutagen::afterCliReady() {
    if ! Mount::Mutagen::createSyncSession; then
        Console::warn "Mutagen sync session creation failed or timed out. Boot will continue."
        Console::warn "You can manually create the session later or retry after fixing Mutagen issues."
        return 0
    fi
    
    if Mount::Mutagen::sessionExists; then
        Console::verbose "${INFO}Flushing file syncronization${NC}"
        Mount::Mutagen::runWithTimeout 10 mutagen sync flush "${SPRYKER_SYNC_SESSION_NAME}" 2>/dev/null || true
    fi
}

function Mount::Mutagen::resumeSessionIfPaused() {
    local sessionName="${1:-${SPRYKER_SYNC_SESSION_NAME}}"
    
    if [ -z "${sessionName}" ]; then
        return 1
    fi
    
    local sessionInfo=$(mutagen sync list "${sessionName}" 2>/dev/null || echo '')
    if [ -z "${sessionInfo}" ]; then
        return 1
    fi
    
    local sessionStatus=$(echo "${sessionInfo}" | grep 'Status:' | awk '{print $2}' | tr -d '[]' || echo '')
    if [ "${sessionStatus}" = 'Paused' ]; then
        Console::verbose "${INFO}Resuming paused sync session: ${sessionName}${NC}"
        mutagen sync resume "${sessionName}" >/dev/null 2>&1 || true
        return 0
    fi
    
    return 1
}

function Mount::Mutagen::findAndResumePausedSession() {
    if [ -n "${SPRYKER_SYNC_SESSION_NAME}" ]; then
        if Mount::Mutagen::resumeSessionIfPaused "${SPRYKER_SYNC_SESSION_NAME}"; then
            return 0
        fi
    fi
    
    local projectPrefix="${SPRYKER_DOCKER_PREFIX:-spryker}"
    local pausedSessions=$(mutagen sync list 2>/dev/null | grep -B 1 'Status:.*\[Paused\]' | grep 'Name:' | awk '{print $2}' || echo '')
    
    for sessionName in ${pausedSessions}; do
        if echo "${sessionName}" | grep -q "${projectPrefix}.*codebase"; then
            Console::verbose "${INFO}Found paused session matching project: ${sessionName}${NC}"
            if Mount::Mutagen::resumeSessionIfPaused "${sessionName}"; then
                return 0
            fi
        fi
    done
    
    return 1
}

function Mount::Mutagen::afterRun() {
    if [ -z "${SPRYKER_SYNC_SESSION_NAME}" ]; then
        return 0
    fi
    
    sleep 2
    
    Mount::Mutagen::ensureDaemonRunning
    
    if Mount::Mutagen::findAndResumePausedSession; then
        Console::verbose "${INFO}Sync session resumed successfully${NC}"
        return 0
    fi
    
    if Mount::Mutagen::sessionExists; then
        Console::verbose "${INFO}Sync session already exists${NC}"
        return 0
    fi
    
    local maxRetries=10
    local retryDelay=2
    local attempt=1
    local targetContainer=""
    
    Console::verbose "${INFO}Attempting to create mutagen sync session...${NC}"
    
    while [ ${attempt} -le ${maxRetries} ]; do
        targetContainer=$(Mount::Mutagen::findTargetContainer)
        
        if [ -n "${targetContainer}" ]; then
            Console::verbose "${INFO}Found container: ${targetContainer}, creating sync session (attempt ${attempt}/${maxRetries})...${NC}"
            if Mount::Mutagen::createSyncSession; then
                sleep 1
                if Mount::Mutagen::sessionExists; then
                    Console::verbose "${INFO}Mutagen sync session created successfully${NC}"
                    return 0
                else
                    Console::verbose "${INFO}Session creation reported success but session not found, retrying...${NC}"
                fi
            else
                Console::verbose "${INFO}Session creation failed, will retry...${NC}"
            fi
        else
            Console::verbose "${INFO}Container not ready yet, waiting... (attempt ${attempt}/${maxRetries})${NC}"
        fi
        
        if [ ${attempt} -lt ${maxRetries} ]; then
            sleep ${retryDelay}
        fi
        
        attempt=$((attempt + 1))
    done
    
    Console::error "Mutagen sync session could not be created automatically after ${maxRetries} attempts."
    Console::error "This means files won't be synced to the container. Please run: docker/sdk sync start"
    return 1
}

function Mount::Mutagen::afterDown() {
    Console::verbose "${INFO}Pruning file syncronization${NC}"
    docker volume rm "${SPRYKER_SYNC_VOLUME}" >/dev/null 2>&1 || true
    
    if Mount::Mutagen::sessionExists; then
        mutagen sync terminate "${SPRYKER_SYNC_SESSION_NAME}" >/dev/null 2>&1 || true
    fi
}

function Mount::Mutagen::afterStop() {
    Console::verbose "${INFO}Pausing sync and stopping mutagen daemon container${NC}"
    
    if Mount::Mutagen::sessionExists; then
        mutagen sync pause "${SPRYKER_SYNC_SESSION_NAME}" >/dev/null 2>&1 || true
    fi
    
    mutagen daemon stop >/dev/null 2>&1 || true
}

function Mount::Mutagen::install() {
	local isMutagenInstalled=$(Mount::Mutagen::isMutagenInstalled)

	if [ -n "${isMutagenInstalled}" ]; then
		Console::error "${isMutagenInstalled}"

		return "${FALSE}"
	fi

	local validateMutagenVersion=$(Mount::Mutagen::validateMutagenVersion)
	if [ -n "${validateMutagenVersion}" ]; then
        Console::error "${validateMutagenVersion}"

        return "${FALSE}"
    fi

    return "${TRUE}"
}

function Mount::Mutagen::getInstalledVersion() {
	echo $(String::trimWhitespaces "$(
         command -v mutagen >/dev/null 2>&1
         # shellcheck disable=SC2015
         test $? -eq 0 && mutagen version
     )")
}

function Mount::Mutagen::getDockerComposeSubstitute() {
	Environment::getDockerComposeSubstitute
}

function Mount::Mutagen::getInstallLink() {
	local dockerComposeInstalledVersion=${1}
	local installLink

    if [ "${dockerComposeInstalledVersion:0:1}" -lt 2 ]; then
        requiredMinimalVersion=${requiredMinimalVersionForDockerComposeV1}
        installLink='mutagen-io/mutagen/mutagen-beta'
    else
        requiredMinimalVersion=${requiredMinimalVersionForDockerComposeV2}
        installLink='mutagen-io/mutagen/mutagen'
    fi

    echo ${installLink}
}

function Mount::Mutagen::getMutagenMinimalVersion() {
	local dockerComposeInstalledVersion=${1}
    local requiredMinimalVersionForDockerComposeV1='0.12.0'
    local requiredMinimalVersionForDockerComposeV2='0.13.0'

	local requiredMinimalVersion

    if [ "${dockerComposeInstalledVersion:0:1}" -lt 2 ]; then
        requiredMinimalVersion=${requiredMinimalVersionForDockerComposeV1}
    else
        requiredMinimalVersion=${requiredMinimalVersionForDockerComposeV2}
    fi

    echo ${requiredMinimalVersion}
}

function Mount::Mutagen::getInstallMessage() {
	local dockerComposeInstalledVersion=${1}
	local installLink=${2}

	local message="brew install ${installLink}"
    local composeInstallLink='mutagen-io/mutagen/mutagen-compose'

    if [ "${dockerComposeInstalledVersion:0:1}" == 2 ]; then
        message+=" ${composeInstallLink}"
    fi

    echo ${message}
}

function Mount::Mutagen::isMutagenInstalled() {
	local dockerComposeInstalledVersion=$(Environment::getDockerComposeVersion)

	local installLink=$(Mount::Mutagen::getInstallLink "${dockerComposeInstalledVersion}")
    local installedVersion=$(Mount::Mutagen::getInstalledVersion)
    local requiredMinimalVersion=$(Mount::Mutagen::getMutagenMinimalVersion "${dockerComposeInstalledVersion}")

    if [ -z "${installedVersion}" ]; then
        errorMessage+="\nMutagen.io binary is not available. Please, install Mutagen.io. Minimum required version is: ${requiredMinimalVersion}.\n"

        if [ "${_PLATFORM}" == 'macos' ]; then
            errorMessage+="$(Mount::Mutagen::getInstallMessage "${dockerComposeInstalledVersion}" "${installLink}")"
        fi

        echo "${errorMessage}"
    fi
}

function Mount::Mutagen::validateMutagenVersion() {
	local dockerComposeInstalledVersion=$(Environment::getDockerComposeVersion)

	local installLink=$(Mount::Mutagen::getInstallLink "${dockerComposeInstalledVersion}")
    local installedVersion=$(Mount::Mutagen::getInstalledVersion)
    local requiredMinimalVersion=$(Mount::Mutagen::getMutagenMinimalVersion "${dockerComposeInstalledVersion}")

    local errorMessage="\n"

    if [ "$(Version::parse "${installedVersion}")" -lt "$(Version::parse "${requiredMinimalVersion}")" ]; then
        errorMessage+="Mutagen.io version ${installedVersion} is not supported. Please, update Mutagen.io to at least ${requiredMinimalVersion}."

        if [ "${_PLATFORM}" == 'macos' ]; then
            errorMessage+="\nbrew list | grep mutagen | xargs ${XARGS_NO_RUN_IF_EMPTY} brew remove && $(Mount::Mutagen::getInstallMessage ${dockerComposeInstalledVersion} ${installLink}) && mutagen daemon stop && mutagen daemon start"
        fi

        echo ${errorMessage}

		Console::error "${errorMessage}"

        return "${FALSE}"
    else
        local parsedInstallVersion=$(Version::parse "${installedVersion}")
        if [ -n "$( echo ${installedVersion} | sed -n '/beta/p')" ] && [ "${parsedInstallVersion:0:2}" -eq 13 ] && [ "$(Environment::IsDockerComposeV2Enabled)" == "${TRUE}" ]; then
			errorMessage+="Mutagen.io version ${installedVersion} is not supported. Please, update Mutagen.io to at least ${requiredMinimalVersion}."

            if [ "${_PLATFORM}" == 'macos' ]; then
                errorMessage+="\nbrew list | grep mutagen | xargs ${XARGS_NO_RUN_IF_EMPTY} brew remove && $(Mount::Mutagen::getInstallMessage ${dockerComposeInstalledVersion} ${installLink}) && mutagen daemon stop && mutagen daemon start"
            fi

            echo "${errorMessage}"
        fi
    fi
}

function Mount::Mutagen::checkMutagenVersion() {
	local isMutagenInstalled=$(Mount::Mutagen::isMutagenInstalled)

	if [ -n "${isMutagenInstalled}" ]; then
		Console::error "${isMutagenInstalled}"

		exit 1
	fi

	local validateMutagenVersion=$(Mount::Mutagen::validateMutagenVersion)
	if [ -n "${validateMutagenVersion}" ]; then
        Console::error "${validateMutagenVersion}"

        exit 1
    fi
}

DOCKER_COMPOSE_SUBSTITUTE="$(Mount::Mutagen::getDockerComposeSubstitute)"

Registry::Flow::addBeforeUp 'Mount::Mutagen::beforeUp'
Registry::Flow::addBeforeRun 'Mount::Mutagen::beforeRun'
Registry::Flow::addAfterRun 'Mount::Mutagen::afterRun'
Registry::Flow::addAfterCliReady 'Mount::Mutagen::afterCliReady'
Registry::Flow::addAfterDown 'Mount::Mutagen::afterDown'
Registry::Flow::addAfterStop 'Mount::Mutagen::afterStop'
Registry::addInstaller 'Mount::Mutagen::install'
Registry::addChecker 'Mount::Mutagen::checkMutagenVersion'
