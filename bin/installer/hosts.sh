#!/bin/bash

set -e

require grep

import environment/docker.sh

INSTALLER_HOSTS_LIST="${1}"

function Installer::hosts() {
    local ipAddress=$(Environment::getDockerIp)
    local record="${ipAddress} ${INSTALLER_HOSTS_LIST}"

    if [ -f "/etc/hosts" ] && ! grep -q "^${record}" /etc/hosts; then
        echo -e "sudo bash -c \"echo '${record}' >> /etc/hosts\""
        return "${FALSE}"
    fi

    return "${TRUE}"
}

Registry::addInstaller "Installer::hosts"
