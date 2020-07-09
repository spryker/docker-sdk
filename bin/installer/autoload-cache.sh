#!/bin/bash

require node npm

function Installer::autoloadCache() {
    return "${TRUE}"
}

Registry::addInstaller "Installer::autoloadCache"
