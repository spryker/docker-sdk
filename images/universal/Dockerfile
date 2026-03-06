# syntax = docker/dockerfile:experimental
ARG SPRYKER_PHP_VERSION=8.4
ARG SPRYKER_NODE_VERSION=24
ARG SPRYKER_NPM_VERSION=10

FROM node:${SPRYKER_NODE_VERSION}-bookworm-slim AS node
ARG SPRYKER_NPM_VERSION
RUN npm install -g npm@${SPRYKER_NPM_VERSION}

FROM spryker/php:${SPRYKER_PHP_VERSION} AS dev-base

ENV SPRYKER_IN_DOCKER=1
ENV COMPOSER_IGNORE_CHROMEDRIVER=1
WORKDIR /data

# Log directory
ENV SPRYKER_LOG_DIRECTORY=/tmp/spryker/logs
RUN mkdir -p /tmp/spryker/logs && chown spryker:spryker /tmp/spryker/logs

# SSH
RUN mkdir -p /home/spryker/.ssh && chmod 0700 /home/spryker/.ssh && chown spryker:spryker -R /home/spryker/.ssh

# PHP-FPM defaults
ENV PHP_FPM_PM=dynamic
ENV PHP_FPM_PM_MAX_CHILDREN=4
ENV PHP_FPM_PM_START_SERVERS=2
ENV PHP_FPM_PM_MIN_SPARE_SERVERS=1
ENV PHP_FPM_PM_MAX_SPARE_SERVERS=2
ENV PHP_FPM_PM_MAX_REQUESTS=500
ENV PHP_FPM_REQUEST_TERMINATE_TIMEOUT=1m

# PHP base config (generic defaults)
COPY context/php/php-fpm.d/worker.conf /usr/local/etc/php-fpm.d/worker.conf
COPY context/php/php.ini /usr/local/etc/php/
COPY context/php/conf.d/90-opcache.ini /usr/local/etc/php/conf.d/
COPY context/php/conf.d/91-opcache-dev.ini /usr/local/etc/php/conf.d/
RUN rm -f /usr/local/etc/php/conf.d/opcache.ini

# NodeJS + NPM
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Blackfire client (always installed, activation is separate)
RUN mkdir -p /tmp/blackfire \
    && architecture=$(case $(uname -m) in i386|i686|x86) echo "i386";; x86_64|amd64) echo "amd64";; aarch64|arm64|armv8) echo "arm64";; *) echo "amd64";; esac) \
    && wget -qO- -U "Docker" https://blackfire.io/api/v1/releases/cli/linux/$architecture | tar zxp -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire /usr/bin/blackfire \
    && rm -Rf /tmp/blackfire

ENV PATH=/data/vendor/bin:/home/spryker/bin:$PATH

# Linux packages (all dev tools including supervisor for debug mode)
RUN apt update -y && apt install -y \
    inotify-tools \
    netcat-openbsd \
    git \
    redis-tools \
    jq \
    python3 \
    g++ \
    make \
    supervisor \
    gosu \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt update -y && apt install -y yarn \
    && rm -rf /var/lib/apt/lists/*

# Debug support directories (pre-created)
RUN /usr/bin/install -d -m 777 /var/run/opcache/debug && mkdir -p /var/log/supervisor

# Spryker user setup
USER spryker
RUN mkdir -p /home/spryker/env \
    && mkdir -p /home/spryker/ssh-relay && chmod 777 /home/spryker/ssh-relay \
    && touch /home/spryker/ssh-relay/ssh-auth.sock && chmod 666 /home/spryker/ssh-relay/ssh-auth.sock \
    && touch /tmp/stdout && touch /tmp/stderr && chmod 666 /tmp/stdout && chmod 666 /tmp/stderr \
    && mkdir -p /home/spryker/history && touch /home/spryker/history/.bash_history && chmod 0600 /home/spryker/history/.bash_history

ENV HISTFILE=/home/spryker/history/.bash_history
ENV NEWRELIC_ENABLED=0
ENV DEVELOPMENT_CONSOLE_COMMANDS=1

USER root
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm", "--nodaemonize"]
EXPOSE 9000
