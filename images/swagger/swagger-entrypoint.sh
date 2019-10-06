#!/bin/sh

set -e

sed -i -e "s|http://localhost|${SPRYKER_SWAGGER_API_HOST}|g" /var/specs/spryker_rest_api.schema.yml

sh /usr/share/nginx/run.sh