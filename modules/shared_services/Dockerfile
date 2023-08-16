FROM spryker_docker_sdk_codebase

WORKDIR /

COPY ./modules/shared_services/shared-services /modules/shared_services/shared-services
RUN composer install -d /modules/shared_services/shared-services --no-interaction --optimize-autoloader

ENTRYPOINT [ "php", "/modules/shared_services/shared-services/index.php" ]
