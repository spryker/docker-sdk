#!/bin/bash

HOST=${HOSTNAME}
PORT=${TCPPORT}
JENKINS_CLI_PATH=${JENKINS_CLI_PATH}

function waitForJenkinsCliEndpointToRespondHealthy(){
  unset STATUS
  while [ $(test -z $${STATUS} && echo 0 || echo $${STATUS} ) -ne 200 ]; do
    echo "Waiting for Jenkins CLI endpoint to respond with a 200 Status Code"
    STATUS=$(curl -s -f http://$${HOST}:$${PORT}/cli/ -o /dev/null -w "%%{http_code}")
    sleep 1
  done
}

function waitForJenkinsToStart(){
  unset STATUS
  while [ $(test -z $${STATUS} && echo 0 || echo $${STATUS} ) -ne 200 ]; do
    echo "Waiting for HTTP port $${PORT} on $${HOST}"
    STATUS=$(curl -s -f http://$${HOST}:$${PORT} -o /dev/null -w "%%{http_code}")
    sleep 2
  done
}

function waitForJenkinsPluginConfigurationAsCodeToStart(){
  unset STATUS
  while [ $(test -z $${STATUS} && echo 0 || echo $${STATUS} ) -ne 200 ]; do
    echo "Waiting for HTTP port $${PORT} on $${HOST}"
    STATUS=$(curl -s -f http://$${HOST}:$${PORT}/configuration-as-code/ -o /dev/null -w "%%{http_code}")
    sleep 2
  done
}

function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

function checkJenkinsVersion {
  JENKINS_VERSION=$(java -jar $${JENKINS_CLI_PATH} -s http://$${HOST}:$${PORT}/ version)
  JENKINS_MINIMUM_VERSION=2.289
  if [ [$(version $${JENKINS_VERSION})] -ge [$(version $${JENKINS_MINIMUM_VERSION})] ]; then
    echo "Version $${JENKINS_VERSION} not supported for newrelic plugin, jenkins $${JENKINS_MINIMUM_VERSION} is the minimum requirement."
    exit
  fi
  echo "Jenkins version requirement (v$${JENKINS_MINIMUM_VERSION}) met: v$${JENKINS_VERSION} installed"
}

waitForJenkinsToStart
waitForJenkinsCliEndpointToRespondHealthy
checkJenkinsVersion

rm -f /root/.jenkins/nr_plugin.zip
rm -f $${JENKINS_CLI_PATH}
wget -O $${JENKINS_CLI_PATH} http://$${HOST}:$${PORT}/jnlpJars/jenkins-cli.jar
waitForJenkinsCliEndpointToRespondHealthy

# java -jar $${JENKINS_CLI_PATH} -s http://$${HOST}:$${PORT}/ install-plugin credentials
# echo "installed jenkins credentials plugin.."
# java -jar $${JENKINS_CLI_PATH} -s http://$${HOST}:$${PORT}/ install-plugin token-macro
# echo "installed jenkins token-macro plugin.."
java -jar $${JENKINS_CLI_PATH} -s http://$${HOST}:$${PORT}/ install-plugin configuration-as-code -restart
echo "installed jenkins configuration-as-code plugin(restart).."
waitForJenkinsToStart
waitForJenkinsCliEndpointToRespondHealthy

java -jar $${JENKINS_CLI_PATH} -s http://$${HOST}:$${PORT}/ delete-credentials system::system::jenkins "(global)" newrelic-insight-key
echo "deleted old newrelic credentials.."
waitForJenkinsCliEndpointToRespondHealthy

java -jar $${JENKINS_CLI_PATH} -s http://$${HOST}:$${PORT}/ create-credentials-by-xml system::system::jenkins "(global)" < /root/.jenkins/nr-credentials.xml
echo "deployed new newrelic credentials.."
waitForJenkinsCliEndpointToRespondHealthy

waitForJenkinsPluginConfigurationAsCodeToStart
curl -v -X POST -T /root/.jenkins/nr-config-as-code.yaml "http://$${HOST}:$${PORT}/configuration-as-code/apply"
echo "deployed and configured jenkins newrelic plugin."
date > /root/.jenkins/nr-plugin-deployed.txt
