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
docker/deployment/default
docker/deployment/default/bin
docker/deployment/default/deploy
docker/deployment/default/docker-compose.test.yml
docker/deployment/default/docker-compose.yml
docker/deployment/default/images
docker/deployment/default/spryker.pfx
docker/deployment/default/context
docker/deployment/default/docker-compose.test.xdebug.yml
docker/deployment/default/docker-compose.xdebug.yml
docker/deployment/default/env
docker/deployment/default/project.yml
docker/deployment/default/bin/boot-deployment.sh
docker/deployment/default/bin/check-docker.sh
docker/deployment/default/bin/console.sh
docker/deployment/default/bin/constants.sh
docker/deployment/default/bin/database
docker/deployment/default/bin/mount
docker/deployment/default/bin/platform.sh
docker/deployment/default/bin/require.sh
docker/deployment/default/bin/database/mysql.sh
docker/deployment/default/bin/database/postgres.sh
docker/deployment/default/bin/mount/baked.sh
docker/deployment/default/bin/mount/docker-sync.sh
docker/deployment/default/bin/mount/native.sh
docker/deployment/default/context/cli
docker/deployment/default/context/mysql
docker/deployment/default/context/nginx
docker/deployment/default/context/php
docker/deployment/default/context/cli/execute.sh
docker/deployment/default/context/mysql/my.cnf
docker/deployment/default/context/nginx/conf.d
docker/deployment/default/context/nginx/dummy
docker/deployment/default/context/nginx/nginx.conf
docker/deployment/default/context/nginx/ssl
docker/deployment/default/context/nginx/stream.d
docker/deployment/default/context/nginx/vhost.d
docker/deployment/default/context/nginx/conf.d/front-end.default.conf
docker/deployment/default/context/nginx/conf.d/zed-rpc.default.conf
docker/deployment/default/context/nginx/dummy/scheduler.conf
docker/deployment/default/context/nginx/ssl/ca.crt
docker/deployment/default/context/nginx/ssl/ca.key
docker/deployment/default/context/nginx/ssl/ca.pfx
docker/deployment/default/context/nginx/ssl/ca.srl
docker/deployment/default/context/nginx/ssl/ssl.crt
docker/deployment/default/context/nginx/ssl/ssl.csr
docker/deployment/default/context/nginx/ssl/ssl.key
docker/deployment/default/context/nginx/stream.d/front-end.default.conf
docker/deployment/default/context/nginx/vhost.d/glue.default.conf
docker/deployment/default/context/nginx/vhost.d/ssl.default.conf
docker/deployment/default/context/nginx/vhost.d/yves.default.conf
docker/deployment/default/context/nginx/vhost.d/zed.default.conf
docker/deployment/default/context/php/conf.d
docker/deployment/default/context/php/php-fpm.d
docker/deployment/default/context/php/php.ini
docker/deployment/default/context/php/conf.d/opcache.ini
docker/deployment/default/context/php/conf.d/opcache_dev.ini
docker/deployment/default/context/php/conf.d/xdebug.ini
docker/deployment/default/context/php/php-fpm.d/worker.conf
docker/deployment/default/env/cli
docker/deployment/default/env/glue_eu.env
docker/deployment/default/env/glue_us.env
docker/deployment/default/env/yves_us.env
docker/deployment/default/env/testing.env
docker/deployment/default/env/yves_eu.env
docker/deployment/default/env/zed_eu.env
docker/deployment/default/env/zed_us.env
docker/deployment/default/env/cli/at.env
docker/deployment/default/env/cli/de.env
docker/deployment/default/env/cli/testing.env
docker/deployment/default/env/cli/us.env
docker/deployment/default/images/base_app
docker/deployment/default/images/base_dev
docker/deployment/default/images/builder_assets
docker/deployment/default/images/cli
docker/deployment/default/images/base_app/Dockerfile
docker/deployment/default/images/base_dev/Dockerfile
docker/deployment/default/images/builder_assets/Dockerfile
docker/deployment/default/images/cli/Dockerfile
)

checkFiles "${bootFileCollection[@]}"
