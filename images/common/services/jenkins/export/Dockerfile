# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE

FROM ${SPRYKER_PARENT_IMAGE}  as spryker_jenkins
EXPOSE 8080

RUN apk --no-cache add curl bash openjdk8 ttf-dejavu gettext jq && \
    mkdir -p /envs

ENV JENKINS_VERSION 2.289
ENV NR_PLUGIN_VERSION 1.0.4

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"

RUN set -x && \
    curl -sSL --create-dirs --retry 1 http://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war -o /usr/share/jenkins/jenkins.war

RUN ls -la

COPY terraform/cli /envs/
COPY context/jenkins/export/entrypoint.sh /entrypoint.sh
COPY context/jenkins/export/jenkins.model.JenkinsLocationConfiguration.xml /opt/jenkins.model.JenkinsLocationConfiguration.xml
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
