#!/bin/bash

set -e

pushd "${BASH_SOURCE%/*}" > /dev/null
. ./constants.sh
. ./console.sh
popd > /dev/null

function analyzeHosts()
{
    local ipAddress=${1}
    local hosts=${2}

    [ -z "${ipAddress}" ] && error "ipAddress is not set."
    [ -z "${hosts}" ] && error "hosts is not set."

    if [ -f "/etc/hosts" ] && [ -z "$(cat "/etc/hosts" | grep "${ipAddress}    ${hosts}")" ];
    then
        echo -e "echo \"echo '${ipAddress}    ${hosts}' >> /etc/hosts\" | sudo bash"
    fi
}

function analyzeNfs()
{
    local userId=${1}
    local groupId=${2}
    local projectPath=${3}
    local host=${4}

    [ -z "${userId}" ] && error "userId is not set."
    [ -z "${groupId}" ] && error "groupId is not set."
    [ -z "${projectPath}" ] && error "projectPath is not set."
    [ -z "${host}" ] && error "host is not set."

    if [ -z "$(cat /etc/exports | grep "${projectPath} -alldirs -mapall=${userId}:${groupId} ${host}")" ];
    then
       echo -e "echo \"echo \\\"${projectPath}\\\" -alldirs -mapall=${userId}:${groupId} ${host} >> /etc/exports && nfsd restart\" | sudo bash"
    fi
}

export -f analyzeHosts
export -f analyzeNfs
