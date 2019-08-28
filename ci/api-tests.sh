#!/usr/bin/env bash

docker/sdk codecept codecept fixtures
docker/sdk codecept console queue:worker:start
sleep 90
docker/sdk codecept codecept run${SPRYKER_CODECEPT_CONFIG}
