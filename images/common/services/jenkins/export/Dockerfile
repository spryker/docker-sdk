# syntax = docker/dockerfile:experimental
ARG SPRYKER_PARENT_IMAGE

FROM spryker/jenkins-boilerplate:latest as spryker-jenkins-boilerplate
FROM ${SPRYKER_PARENT_IMAGE}  as spryker_jenkins
EXPOSE 8080
COPY context/jenkins/export/jenkins.docker.xml.twig ./config/Zed/cronjobs/jenkins.docker.xml.twig

COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/ref/plugins /usr/share/jenkins/ref/plugins
COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/jenkins.war /usr/share/jenkins/jenkins.war
COPY --from=spryker-jenkins-boilerplate /usr/share/jenkins/jenkins-cli.jar /usr/share/jenkins/jenkins-cli.jar

RUN apk --no-cache add curl bash openjdk8 ttf-dejavu gettext jq && \
    mkdir -p /envs

COPY terraform/cli /envs/
COPY context/jenkins/export/entrypoint.sh /entrypoint.sh
COPY context/jenkins/export/jenkins.model.JenkinsLocationConfiguration.xml /opt/jenkins.model.JenkinsLocationConfiguration.xml
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
