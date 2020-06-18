#!/bin/bash

import sdk/images/common.sh

function Images::build() {
    Images::buildApp mount
    Images::buildCli mount
    Images::tagAll "${SPRYKER_DOCKER_TAG}"
}
