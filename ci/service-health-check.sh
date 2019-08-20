#!/usr/bin/env bash

function healthCheckService() {
    local SERVICE_URL=$1
    local HTTP_STATUS_CODE=$(curl -L --silent -s -o /dev/null -w '%{http_code}' ${SERVICE_URL})

    if [ ${HTTP_STATUS_CODE} -eq 000 ] || [ ${HTTP_STATUS_CODE} -ge 500 ]; then
        echo "${SERVICE_URL} is unavailable with ${HTTP_STATUS_CODE} status code."

        return 1
    fi

    return 0
}

healthCheckService 'yves.de.demo-spryker.com'
healthCheckService 'glue.de.demo-spryker.com'
healthCheckService 'zed.de.demo-spryker.com'
healthCheckService 'queue.demo-spryker.com'
healthCheckService 'scheduler.demo-spryker.com'
#TODO: add DB check
