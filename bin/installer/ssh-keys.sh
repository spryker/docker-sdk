#!/bin/bash

function Installer::ssh-keys() {
    local privateKeyFileName='dev_only_private.key'
    local publicKeyFileName='dev_only_public.key'
    local sshDirPath=${DEPLOYMENT_PATH}/context/ssh

    mkdir ${sshDirPath}

    openssl genrsa -out ${sshDirPath}/${privateKeyFileName} 2048 >/dev/null 2>&1 || true
    openssl rsa -in ${sshDirPath}/${privateKeyFileName} -pubout -out ${DEPLOYMENT_PATH}/context/ssh/${publicKeyFileName} >/dev/null 2>&1 || true


    return "${TRUE}"
}

Registry::addInstaller "Installer::ssh-keys"
