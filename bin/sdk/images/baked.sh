#!/bin/bash

import sdk/images/common.sh

function Images::build() {
    Images::buildApp baked
    Images::buildCli baked
    Images::tagAll "${SPRYKER_DOCKER_TAG}"
}
