#!/bin/bash

function Installer::jenkins-template() {

    local fileName='./config/Zed/cronjobs/jenkins.docker.xml.twig'

    if [ -f "${fileName}" ]; then
        Console::warn "Warning: Jenkins job template is found on project level: ${fileName}."
        Console::warn "         It is better to delete the file as it will not be used by docker/sdk."
        return "${FALSE}"
    fi

    return "${TRUE}"
}

Registry::addInstaller "Installer::jenkins-template"
