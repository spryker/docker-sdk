#!/bin/bash

import environment/docker.sh
import environment/get-real-project-path.sh

function Installer::nfsExports() {
    local userId=$(id -u)
    local groupId=$(id -g)
    local projectPath=$(Environment::getRealProjectPath)
    local host=$(Environment::getDockerIp)

    local record="${projectPath} -alldirs -mapall=${userId}:${groupId} ${host}"

    if ! grep -q "${record}" /etc/exports; then
        echo -e "sudo bash -c \"echo '' >> /etc/exports && echo '${record}' >> /etc/exports && nfsd restart\""
        return "${FALSE}"
    fi

    return "${TRUE}"
}

function Installer::nfsConfig() {

    local configFile="/etc/nfs.conf"
    local record="nfs.server.mount.require_resv_port = 0"

    if [ ! -f ${configFile} ] || ! grep -q "${record}" /etc/nfs.conf; then
        echo -e "sudo bash -c \"touch ${configFile} && echo '' >> ${configFile} && echo '${record}' >> ${configFile} && nfsd restart\""
        return "${FALSE}"
    fi

    return "${TRUE}"
}

Registry::addInstaller "Installer::nfsExports"
Registry::addInstaller "Installer::nfsConfig"
