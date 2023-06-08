# syntax = docker/dockerfile:1.5
ARG SPRYKER_PARENT_IMAGE

FROM spryker/jenkins-boilerplate:2.361.1 as spryker-jenkins-boilerplate
FROM ${SPRYKER_PARENT_IMAGE}  as spryker_jenkins
EXPOSE 8080
COPY context/jenkins/export/jenkins.docker.xml.twig ./config/Zed/cronjobs/jenkins.docker.xml.twig
COPY --chown=spryker:spryker context/jenkins/jenkins.docker.xml.twig /home/spryker/jenkins.docker.xml.twig

COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/ref/plugins /usr/share/jenkins/ref/plugins
COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/jenkins.war /usr/share/jenkins/jenkins.war
COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/jenkins-cli.jar /usr/share/jenkins/jenkins-cli.jar

#    openjdk11-jre-headless fontconfig ttf-dejavu \
# Install packages on Alpine
RUN sh -c 'if [ ! -z "$(which apk)" ]; then apk --no-cache add \
	curl \
    bash \
    openjdk11-jre fontconfig ttf-dejavu gettext \
    jq && \
    mkdir -p /envs \
    ; fi'

## Otherwise Jenkins can't find fonts when running in headless mode
#ENV LD_LIBRARY_PATH=/usr/lib

# Install packages on Debian
RUN sh -c 'if [ ! -z "$(which apt)" ]; then apt update -y && \
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
COPY context/jenkins/export/nr-credentials.xml /opt/nr-credentials.xml
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# TBD: Do we need /data/src on Jenkins or /data/vendor is enough
