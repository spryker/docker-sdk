#!/bin/bash

Registry::addCommand "robot-framework" "Command::robot-framework"

Registry::Help::command -c "robot-framework" "Run tests with Robot-Framework."

function Command::robot-framework() {
    Console::verbose::start "Building generator..."
    docker build -t robot_framework_docker_sdk \
        -f "`pwd`/docker/generator/robot-framework/Dockerfile" \
        . 1>&2

    networks=$(docker network ls --format '{{.Name}}' | grep '_private$')

    Console::info "${INFO}Running robot-framework${NC}"
    docker run --rm -it --network=${networks} \
        -v `pwd`/results:/opt/robotframework/results:Z \
        -v /Users/artemstromets/Work/cloud/robotframework-suite-tests:/opt/robotframework:Z \
        robot_framework_docker_sdk ${@}

    Console::end "[DONE]"
    return "${TRUE}"
}
