#!/bin/bash

function Sentinel::Autoload::install() {
    echo 1
}

function Sentinel::Autoload::run() {
# TODO Sentinels
    local host=$(Environment::getDockerIp)
    pm2 start autoload-watch --name "my-api" -v
}

function Sentinel::Autoload::clean() {
    pm2 stop
}

Registry::addChecker 'Sentinel::Autoload::install'
Registry::Flow::addBeforeRun 'Sentinel::Autoload::run'
Registry::Flow::addAfterDown 'Sentinel::Autoload::down'
