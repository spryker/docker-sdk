FROM spryker/jenkins-boilerplate:2.361.1 as jenkins-boilerplate
LABEL "spryker.image" "none"

FROM application-before-stamp as jenkins
LABEL "spryker.image" "jenkins"

EXPOSE 8080
COPY ${DEPLOYMENT_PATH}/context/jenkins/export/jenkins.docker.xml.twig ./config/Zed/cronjobs/jenkins.docker.xml.twig

COPY --from=jenkins-boilerplate /usr/share/jenkins/ref/plugins /usr/share/jenkins/ref/plugins
COPY --from=jenkins-boilerplate /usr/share/jenkins/jenkins.war /usr/share/jenkins/jenkins.war
COPY --from=jenkins-boilerplate /usr/share/jenkins/jenkins-cli.jar /usr/share/jenkins/jenkins-cli.jar

# Install packages on Alpine
RUN --mount=type=cache,id=apk,sharing=locked,target=/var/cache/apk mkdir -p /etc/apk && ln -vsf /var/cache/apk /etc/apk/cache && \
  bash -c 'if [ ! -z "$(which apk)" ]; then apk update && apk add \
	  curl \
    bash \
    openjdk11 \
    ttf-dejavu \
    gettext \
    jq && \
    mkdir -p /envs \
    ; fi'

# Install packages on Debian
RUN --mount=type=cache,id=aptlib,sharing=locked,target=/var/lib/apt \
  --mount=type=cache,id=aptcache,sharing=locked,target=/var/cache/apt \
  bash -c 'if [ ! -z "$(which apt)" ]; then apt update -y && \
    apt-get install -y software-properties-common && \
	  apt-add-repository "deb http://security.debian.org/debian-security bullseye-security main" && \
	  apt-add-repository "deb http://ftp.de.debian.org/debian bullseye main" && \
    apt update -y && apt install -y \
    curl \
      bash \
      openjdk-11-jdk \
      fonts-dejavu \
      gettext \
      jq \
      && \
      mkdir -p /envs \
      ; fi'

COPY ${DEPLOYMENT_PATH}/terraform/cli /envs/
COPY ${DEPLOYMENT_PATH}/context/jenkins/export/entrypoint.sh /entrypoint.sh
COPY ${DEPLOYMENT_PATH}/context/jenkins/export/jenkins.model.JenkinsLocationConfiguration.xml /opt/jenkins.model.JenkinsLocationConfiguration.xml
COPY context/jenkins/export/nr-credentials.xml /opt/nr-credentials.xml
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

ARG SPRYKER_BUILD_HASH
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}
