#!/bin/bash

export COMPOSE_HTTP_TIMEOUT=400
export COMPOSE_CONVERT_WINDOWS_PATHS=1

require docker-compose tr

function Environment::checkDockerComposeVersion() {
    Console::verbose::start "Checking docker-compose version..."

    local requiredMinimalVersion=${1:-'1.22.0'}
    local installedVersion=$(Environment::getDockerComposeVersion)

    if [ "${installedVersion}" == 0 ]; then
        Console::error "Docker Compose is not found. Please, make sure Docker Compose is installed."
        exit 1
    fi

    if [ "$(Version::parse "${installedVersion}")" -lt "$(Version::parse "${requiredMinimalVersion}")" ]; then
        Console::error "Docker Compose version ${installedVersion} is not supported. Please update Docker Compose to at least ${requiredMinimalVersion}."
        exit 1
    fi

    updateComposeCovertWindowsPaths

    Console::end "[OK]"
}

function Environment::getDockerComposeVersion() {
    local composeVersion="$(
       docker compose version >/dev/null 2>&1
       test $? -eq 0 && docker compose version --short | tr -d 'v' || echo 0
    )"

	if [ "${composeVersion}" == '0' ]; then
         composeVersion="$(
             docker-compose version >/dev/null 2>&1
             test $? -eq 0 && docker-compose version --short | tr -d 'v' || echo 0
         )"
	fi

	echo ${composeVersion};
}

# Check `Use Docker compose v2` enabler into Docker Desktop
function Environment::IsDockerComposeV2Enabled() {
	local isDockerComposeV2Enabled="${FALSE}"

	if [ "${_PLATFORM}" != 'linux' ]; then
		local composeVersion=$(Version::parse "$(docker-compose version --short)")

		if [ "${composeVersion:0:1}" -eq 2 ]; then
	         isDockerComposeV2Enabled="${TRUE}"
		fi
	fi

	echo ${isDockerComposeV2Enabled};
}

function Environment::getDockerComposeSubstitute() {
	local dockerComposeVersion=$(Version::parse "$(Environment::getDockerComposeVersion)")

    if [ "${dockerComposeVersion:0:1}" -lt 2 ]; then
        echo 'docker-compose'
    else
        echo 'docker compose'
    fi
}

# For avoid https://github.com/docker/compose/issues/9104
function Environment::getDockerComposeTTY() {
  local ttyDisabledKey='docker_compose_tty_disabled'
  local ttyEnabledKey='docker_compose_tty_enabled'
  local installedVersion=$(Version::parse "$(Environment::getDockerComposeVersion)")

  if [ "${installedVersion:0:1}" -ge 2 ]; then
    echo "${ttyDisabledKey}"
  else
    echo "${ttyEnabledKey}"
  fi
}

# https://github.com/docker/compose/issues/9428
function updateComposeCovertWindowsPaths() {
    local dockerComposeVersion="2.5.0"

    if [ "$(Version::parse "${installedVersion}")" -ge "$(Version::parse "${dockerComposeVersion}")" ]; then
        export COMPOSE_CONVERT_WINDOWS_PATHS=0
    fi
}

Registry::addChecker 'Environment::checkDockerComposeVersion'
