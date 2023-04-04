#!/bin/bash

set -e

echo "> ${COMMAND}"

http_response=$(curl --request POST -LsS \
    -o /dev/stderr \
    -w "%{http_code}" \
    --data "APPLICATION_STORE='${APPLICATION_STORE}' SPRYKER_CURRENT_REGION='${SPRYKER_CURRENT_REGION}' COMMAND='${COMMAND}' cli.sh" \
    --max-time 1000 \
    --url "http://cli:9000/console")

if [ "${http_response}" != "200" ]; then
    exit 1
fi
