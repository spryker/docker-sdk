FROM ${SPRYKER_PLATFORM_IMAGE} AS application-basic
LABEL "spryker.image" "none"

ENV SPRYKER_IN_DOCKER=1
ENV COMPOSER_IGNORE_CHROMEDRIVER=1
ENV SPRYKER_JENKINS_TEMPLATE_PATH=/home/spryker/jenkins.docker.xml.twig
{% for envName, envValue in _envs %}
ENV {{ envName }}='{{ envValue }}'
{% endfor %}

# PHP-FPM environment variables
ENV PHP_FPM_PM=dynamic
ENV PHP_FPM_PM_MAX_CHILDREN=4
ENV PHP_FPM_PM_START_SERVERS=2
ENV PHP_FPM_PM_MIN_SPARE_SERVERS=1
ENV PHP_FPM_PM_MAX_SPARE_SERVERS=2
ENV PHP_FPM_PM_MAX_REQUESTS=500
ENV PHP_FPM_REQUEST_TERMINATE_TIMEOUT=1m

WORKDIR /data

ARG DEPLOYMENT_PATH
COPY ${DEPLOYMENT_PATH}/context/php/php-fpm.d/worker.conf /usr/local/etc/php-fpm.d/worker.conf
COPY ${DEPLOYMENT_PATH}/context/php/php.ini /usr/local/etc/php/
COPY ${DEPLOYMENT_PATH}/context/php/conf.d/90-opcache.ini /usr/local/etc/php/conf.d
COPY ${DEPLOYMENT_PATH}/context/php/conf.d/99-from-deploy-yaml-php.ini /usr/local/etc/php/conf.d/
COPY --link --chown=spryker:spryker ${DEPLOYMENT_PATH}/context/jenkins/jenkins.docker.xml.twig /home/spryker/jenkins.docker.xml.twig
COPY --link --chown=spryker:spryker ${DEPLOYMENT_PATH}/context/php/build.php /home/spryker/build.php

ARG SPRYKER_LOG_DIRECTORY
ARG KNOWN_HOSTS
ENV SPRYKER_LOG_DIRECTORY=${SPRYKER_LOG_DIRECTORY}
RUN <<EOT bash -e
  mkdir -p ${SPRYKER_LOG_DIRECTORY}
  chown spryker:spryker ${SPRYKER_LOG_DIRECTORY}
  mkdir -p /home/spryker/.ssh
  chmod 0700 /home/spryker/.ssh
  if [ ! -z "${KNOWN_HOSTS}" ]; then
    ssh-keyscan -t rsa ${KNOWN_HOSTS} >> /home/spryker/.ssh/known_hosts
  fi
  chown spryker:spryker -R /home/spryker/.ssh
  rm -f /usr/local/etc/php/conf.d/opcache.ini
{% if _phpExtensions is defined and _phpExtensions is not empty %}
{% for phpExtention in _phpExtensions %}
  mv /usr/local/etc/php/disabled/{{phpExtention}}.ini /usr/local/etc/php/conf.d/90-{{phpExtention}}.ini
{% endfor %}
{% endif %}
  rm -rf /var/run
  /usr/bin/install -d -m 777 /var/run/opcache
  php -r 'exit(PHP_VERSION_ID > 70400 ? 1 : 0);' && sed -i '' -e 's/decorate_workers_output/;decorate_workers_output/g' /usr/local/etc/php-fpm.d/worker.conf || true
EOT

ARG SPRYKER_PIPELINE
ENV SPRYKER_PIPELINE=${SPRYKER_PIPELINE}
ARG SPRYKER_DB_ENGINE
ENV SPRYKER_DB_ENGINE=${SPRYKER_DB_ENGINE}
ARG APPLICATION_ENV
ENV APPLICATION_ENV=${APPLICATION_ENV}
ENV PATH=${srcRoot}/vendor/bin:$PATH
