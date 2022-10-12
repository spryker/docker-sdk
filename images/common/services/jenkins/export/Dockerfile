# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE

FROM spryker/jenkins-boilerplate:2.361.1 as spryker-jenkins-boilerplate
FROM ${SPRYKER_PARENT_IMAGE}  as spryker_jenkins
EXPOSE 8080
COPY context/jenkins/export/jenkins.docker.xml.twig ./config/Zed/cronjobs/jenkins.docker.xml.twig

COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/ref/plugins /usr/share/jenkins/ref/plugins
COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/jenkins.war /usr/share/jenkins/jenkins.war
COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/jenkins-cli.jar /usr/share/jenkins/jenkins-cli.jar

# Install packages on Alpine
RUN bash -c 'if [ ! -z "$(which apk)" ]; then apk --no-cache add \
	curl \
    bash \
    openjdk11 \
    ttf-dejavu \
    gettext \
    jq && \
    mkdir -p /envs \
    ; fi'

# Install packages on Debian
RUN bash -c 'if [ ! -z "$(which apt)" ]; then apt update -y && \
	apt-get install -y software-properties-common && \
	apt-add-repository "deb http://security.debian.org/debian-security stretch/updates main" && \
	apt-add-repository "deb http://ftp.de.debian.org/debian buster main" && \
	apt update -y && apt install -y \
	curl \
    bash \
    openjdk-11-jdk \
    ttf-dejavu \
    gettext \
    jq \
    && \
    mkdir -p /envs \
    ; fi'

COPY terraform/cli /envs/
COPY context/jenkins/export/entrypoint.sh /entrypoint.sh
COPY context/jenkins/export/jenkins.model.JenkinsLocationConfiguration.xml /opt/jenkins.model.JenkinsLocationConfiguration.xml
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
