#!/usr/bin/env bash

function checkFiles()
{
    arr=("$@")
    result=0
    for file in "${arr[@]}"; do
        if [[ ! -e "$file" ]]; then
            result=1
            echo  "$file doesn't exist."
        fi
    done

    return ${result}
}

bootFileCollection=(
deployment/default
deployment/default/bin
deployment/default/deploy
deployment/default/docker-compose.test.yml
deployment/default/docker-compose.yml
deployment/default/images
deployment/default/spryker.pfx
deployment/default/context
deployment/default/docker-compose.test.xdebug.yml
deployment/default/docker-compose.xdebug.yml
deployment/default/env
deployment/default/project.yml
deployment/default/bin/boot-deployment.sh
deployment/default/bin/check-docker.sh
deployment/default/bin/check-docker-compose.sh
deployment/default/bin/console.sh
deployment/default/bin/constants.sh
deployment/default/bin/database
deployment/default/bin/mount
deployment/default/bin/platform.sh
deployment/default/bin/require.sh
deployment/default/bin/database/mysql.sh
deployment/default/bin/database/postgres.sh
deployment/default/bin/mount/baked.sh
deployment/default/bin/mount/docker-sync.sh
deployment/default/bin/mount/native.sh
deployment/default/context/cli
deployment/default/context/mysql
deployment/default/context/nginx
deployment/default/context/php
deployment/default/context/cli/execute.sh
deployment/default/context/mysql/my.cnf
deployment/default/context/nginx/conf.d
deployment/default/context/nginx/dummy
deployment/default/context/nginx/nginx.conf
deployment/default/context/nginx/ssl
deployment/default/context/nginx/stream.d
deployment/default/context/nginx/vhost.d
deployment/default/context/nginx/conf.d/front-end.default.conf
deployment/default/context/nginx/conf.d/zed-rpc.default.conf
deployment/default/context/nginx/dummy/scheduler.conf
deployment/default/context/nginx/ssl/ca.crt
deployment/default/context/nginx/ssl/ca.key
deployment/default/context/nginx/ssl/ca.pfx
deployment/default/context/nginx/ssl/ca.srl
deployment/default/context/nginx/ssl/ssl.crt
deployment/default/context/nginx/ssl/ssl.csr
deployment/default/context/nginx/ssl/ssl.key
deployment/default/context/nginx/stream.d/front-end.default.conf
deployment/default/context/nginx/vhost.d/glue.default.conf
deployment/default/context/nginx/vhost.d/ssl.default.conf
deployment/default/context/nginx/vhost.d/yves.default.conf
deployment/default/context/nginx/vhost.d/zed.default.conf
deployment/default/context/php/conf.d
deployment/default/context/php/php-fpm.d
deployment/default/context/php/php.ini
deployment/default/context/php/conf.d/opcache.ini
deployment/default/context/php/conf.d/opcache_dev.ini
deployment/default/context/php/conf.d/xdebug.ini
deployment/default/context/php/php-fpm.d/worker.conf
deployment/default/env/cli
deployment/default/env/glue_eu.env
deployment/default/env/testing.env
deployment/default/env/yves_eu.env
deployment/default/env/zed_eu.env
deployment/default/env/cli/de.env
deployment/default/env/cli/testing.env
deployment/default/images/base_app
deployment/default/images/base_dev
deployment/default/images/builder_assets
deployment/default/images/demo/cli
deployment/default/images/dev/cli
deployment/default/images/base_app/Dockerfile
deployment/default/images/base_dev/Dockerfile
deployment/default/images/builder_assets/Dockerfile
deployment/default/images/cli/Dockerfile
)

checkFiles "${bootFileCollection[@]}"
