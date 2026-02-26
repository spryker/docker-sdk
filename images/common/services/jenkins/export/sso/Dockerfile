# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE

FROM spryker/jenkins-boilerplate:latest as spryker-jenkins-boilerplate
FROM ${SPRYKER_PARENT_IMAGE}  as spryker_jenkins
EXPOSE 8080
COPY context/jenkins/export/jenkins.docker.xml.twig ./config/Zed/cronjobs/jenkins.docker.xml.twig

COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/ref/plugins /usr/share/jenkins/ref/plugins
COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/jenkins.war /usr/share/jenkins/jenkins.war
COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/jenkins-cli.jar /usr/share/jenkins/jenkins-cli.jar
COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/ref/casc.yaml /usr/share/jenkins/ref/casc.yaml
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d
COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/ref/init.groovy.d/bootstrap_token.groovy /usr/share/jenkins/ref/init.groovy.d/bootstrap_token.groovy
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV CASC_JENKINS_CONFIG=/usr/share/jenkins/ref/casc.yaml

# Install packages on Alpine
RUN bash -c 'if [ ! -z "$(which apk)" ]; then apk --no-cache add \
	curl \
    bash \
    openjdk17 \
    ttf-dejavu \
    gettext \
    jq \
    ca-certificates \
    aws-cli && \
    mkdir -p /envs \
    ; fi'

# Install packages on Debian
RUN bash -c 'if [ ! -z "$(which apt)" ]; then apt update -y && \
	apt-get install -y software-properties-common && \
	apt-add-repository "deb http://security.debian.org/debian-security bullseye-security main" && \
	apt-add-repository "deb http://ftp.de.debian.org/debian bullseye main" && \
	apt update -y && apt install -y \
	curl \
    bash \
    openjdk-17-jdk \
    fonts-dejavu \
    gettext \
    jq \
    ca-certificates \
    unzip && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws && \
    mkdir -p /envs \
    ; fi'

COPY terraform/cli /envs/
COPY context/jenkins/export/entrypoint-sso.sh /entrypoint.sh
COPY context/jenkins/export/jenkins.model.JenkinsLocationConfiguration.xml /opt/jenkins.model.JenkinsLocationConfiguration.xml
COPY context/jenkins/export/com.newrelic.experts.jenkins.extensions.NewRelicGlobalConfiguration.xml /opt/com.newrelic.experts.jenkins.extensions.NewRelicGlobalConfiguration.xml
COPY context/jenkins/export/nr-credentials.xml /opt/nr-credentials.xml
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
