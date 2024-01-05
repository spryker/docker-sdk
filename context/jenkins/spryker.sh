#!/bin/bash

set -e

echo "> ${COMMAND}"

: "${JENKINS_MAX_TIME:=1000}"
if [ "${JENKINS_MAX_TIME}" == "0" ]; then
    MAX_TIME=''
else
    MAX_TIME="--max-time ${JENKINS_MAX_TIME}"
fi

echo "MAX_TIME = ${MAX_TIME}";

http_response=$(curl --request POST -LsS \
    -o /dev/stderr \
    -w "%{http_code}" \
    --data "APPLICATION_STORE='${APPLICATION_STORE}' SPRYKER_CURRENT_REGION='${SPRYKER_CURRENT_REGION}' COMMAND='${COMMAND}' cli.sh" \
    --max-time ${JENKINS_MAX_TIME} \
    --url "http://cli:9000/console")

if [ "${http_response}" != "200" ]; then
    exit 1
fi
