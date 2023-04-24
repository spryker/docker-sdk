#!/bin/bash

HOST=localhost
PORT=8080
JENKINS_CLI_PATH="/usr/share/jenkins/jenkins-cli.jar"

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

function waitForJenkinsCliEndpointToRespondHealthy(){
  unset STATUS
  while [ $(test -z ${STATUS} && echo 0 || echo ${STATUS} ) -ne 200 ]; do
    echo "Waiting for Jenkins CLI endpoint to respond with a 200 Status Code"
    STATUS=$(curl -s -f http://${HOST}:${PORT}/cli/ -o /dev/null -w "%{http_code}")
    sleep 1
  done
}

mkdir -p ~/.jenkins/updates
rm -rf ~/.jenkins/plugins || echo 'plugins did not exists anyway'
mkdir -p ~/.jenkins/plugins
test -f ~/.jenkins/jenkins.model.JenkinsLocationConfiguration.xml || envsubst < /opt/jenkins.model.JenkinsLocationConfiguration.xml > ~/.jenkins/jenkins.model.JenkinsLocationConfiguration.xml
test -f ~/.jenkins/nr-credentials.xml || envsubst < /opt/nr-credentials.xml > ~/.jenkins/nr-credentials.xml

trap 'waitForFinishOfActiveJobs; kill ${pid}; exit 0;' SIGTERM
cp -r /usr/share/jenkins/ref/plugins/* /root/.jenkins/plugins/
java ${JAVA_OPTS} -Djenkins.install.runSetupWizard=false -jar /usr/share/jenkins/jenkins.war ${JENKINS_OPTS} & pid=$!

waitForJenkinsToStart
echo "HTTP port ${PORT} on ${HOST} all started up.."

rm -f ${JENKINS_CLI_PATH}
wget -O ${JENKINS_CLI_PATH} http://${HOST}:${PORT}/jnlpJars/jenkins-cli.jar
waitForJenkinsCliEndpointToRespondHealthy

java -jar ${JENKINS_CLI_PATH} -s http://${HOST}:${PORT}/ delete-credentials system::system::jenkins "(global)" newrelic-insight-key
echo "deleted old newrelic credentials.."
waitForJenkinsCliEndpointToRespondHealthy

java -jar ${JENKINS_CLI_PATH} -s http://${HOST}:${PORT} create-credentials-by-xml system::system::jenkins "(global)" < ~/.jenkins/nr-credentials.xml
echo "deployed new newrelic credentials.."
waitForJenkinsCliEndpointToRespondHealthy

### uncomment these two lines if datadog agent shall be installed
# curl -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' > /root/.jenkins/updates/default.json
# java -jar jenkins-cli.jar -s http://${HOST}:${PORT} install-plugin datadog -restart

wait ${pid}
