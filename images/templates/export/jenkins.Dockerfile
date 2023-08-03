FROM spryker/jenkins-boilerplate:2.361.1 as jenkins-boilerplate
LABEL "spryker.image" "none"

FROM application-before-stamp as jenkins
LABEL "spryker.image" "jenkins"

COPY --link --from=jenkins-boilerplate /usr/share/jenkins /usr/share/jenkins

ARG DEPLOYMENT_PATH
COPY --link ${DEPLOYMENT_PATH}/terraform/cli /envs/
COPY --link ${DEPLOYMENT_PATH}/context/jenkins/export/jenkins.model.JenkinsLocationConfiguration.xml /opt/jenkins.model.JenkinsLocationConfiguration.xml
COPY --link ${DEPLOYMENT_PATH}/context/jenkins/export/nr-credentials.xml /opt/nr-credentials.xml

COPY --link --chmod=755 ${DEPLOYMENT_PATH}/context/jenkins/export/entrypoint.sh /entrypoint.sh

COPY --link --chown=spryker:spryker .* *.* ${srcRoot}

ARG SPRYKER_DB_ENGINE
RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk \
  --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
  --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  <<EOT bash -e
    if which apk; then
      mkdir -p /etc/apk
      ln -vsf /var/cache/apk /etc/apk/cache
      apk update
      apk add \
        $(if [ "${SPRYKER_DB_ENGINE}" == 'pgsql' ]; then echo 'postgresql-client'; else echo 'mysql-client'; fi) \
        openjdk11 \
        ttf-dejavu \
        gettext \
        jq
    else
      export DEBIAN_FRONTEND=noninteractive
      apt install -y software-properties-common
      VERSION_CODENAME=$(env -i bash -c '. /etc/os-release; echo ${VERSION_CODENAME}')
	    apt-add-repository "deb http://security.debian.org/debian-security \${VERSION_CODENAME}-security main"
	    apt-add-repository "deb http://ftp.de.debian.org/debian \${VERSION_CODENAME} main"
      apt update -y
      apt install -y \
        $(if [ "${SPRYKER_DB_ENGINE}" == 'pgsql' ]; then echo 'postgresql-client'; else echo 'default-mysql-client'; fi) \
        openjdk-11-jdk \
        fonts-dejavu \
        gettext \
        jq
      apt remove -y software-properties-common
      apt-get --purge -y autoremove
    fi
EOT

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]

ARG SPRYKER_BUILD_HASH
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}
