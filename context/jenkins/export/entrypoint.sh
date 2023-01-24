#!/bin/bash

HOST=localhost
PORT=8080

function suspendJenkins(){
  curl -sLI -X POST http://${HOST}:${PORT}/quietDown
}

function countRunningJobs(){
  curl -s http://${HOST}:${PORT}/computer/api/json|jq .busyExecutors
}

function waitForFinishOfActiveJobs(){
  suspendJenkins

  COUNT=$(countRunningJobs|wc -l)

  while test ${COUNT} -gt 0; do
    COUNT=$(countRunningJobs)
    echo "Active jobs count: ${COUNT}"
    sleep 1
  done
  echo "No running jobs. Exiting..."
}

function waitForJenkinsToStart(){
  while [ $(test -z ${STATUS} && echo 0 || echo ${STATUS} ) -ne 200 ]; do
    echo "Waiting for HTTP port ${PORT} on ${HOST}.."
    STATUS=$(curl -s -f http://${HOST}:${PORT} -o /dev/null -w "%{http_code}")
    sleep 1
  done
}

mkdir -p ~/.jenkins/updates
rm -rf ~/.jenkins/plugins || echo 'plugins did not exists anyway'
mkdir -p ~/.jenkins/plugins
test -f ~/.jenkins/jenkins.model.JenkinsLocationConfiguration.xml || envsubst < /opt/jenkins.model.JenkinsLocationConfiguration.xml > ~/.jenkins/jenkins.model.JenkinsLocationConfiguration.xml

trap 'waitForFinishOfActiveJobs; kill ${pid}; exit 0;' SIGTERM
cp -r /usr/share/jenkins/ref/plugins/* /root/.jenkins/plugins/
java ${JAVA_OPTS} -Djenkins.install.runSetupWizard=false -jar /usr/share/jenkins/jenkins.war ${JENKINS_OPTS} & pid=$!

waitForJenkinsToStart
echo "HTTP port ${PORT} on ${HOST} all started up.."
test ! -f /usr/share/jenkins/jenkins-cli.jar && wget ${HOST}:${PORT}/jnlpJars/jenkins-cli.jar

### uncomment these two lines if datadog agent shall be installed
# curl -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' > /root/.jenkins/updates/default.json
# java -jar jenkins-cli.jar -s http://${HOST}:${PORT} install-plugin datadog -restart

wait ${pid}
