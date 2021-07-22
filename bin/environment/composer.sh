#!/bin/bash

function Environment::Composer() {

    if [ -z "${GITHUB_TOKEN}" ] && [ -z "${SSH_AUTH_SOCK}" ] && [ -z "${COMPOSER_AUTH}" ]; then
        Console::error "Warning: Neither SSH agent or COMPOSER_AUTH is configured. Private repositories would not be accessible."
    fi

    if [ -n "${SSH_AUTH_SOCK}" ] && [ -n "${COMPOSER_AUTH}${GITHUB_TOKEN}" ]; then
        Console::error "Warning: SSH agent will not work when COMPOSER_AUTH or GITHUB_TOKEN are configured."
    fi

    return "${TRUE}"
}

Registry::addChecker "Environment::Composer"
