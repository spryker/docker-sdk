#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-localhost}"
PORT="${PORT:-8080}"

# === marker & token produced by Groovy ===
BOOTSTRAP_DIR="/root/.jenkins/secrets/bootstrap"
MARKER_FILE="${BOOTSTRAP_DIR}/.token_ready"
SPRYKER_SCHEDULER_USER="${SPRYKER_SCHEDULER_USER:-}"   # optional; will auto-detect if empty
TOKEN_FILE="${BOOTSTRAP_DIR}/${SPRYKER_SCHEDULER_USER:-}.token"

# Will be filled after reading token
AUTH_CURL=()
TOKEN_VALUE=""

# --- helpers (auth-aware once AUTH_CURL is set) ---
getCrumb() {
  # Returns 'Jenkins-Crumb:<crumb>' or empty if endpoint not enabled
  curl -sf "http://${HOST}:${PORT}/crumbIssuer/api/json" \
    "${AUTH_CURL[@]}" 2>/dev/null \
    | jq -r '"Jenkins-Crumb:"+.crumb' 2>/dev/null || true
}

suspendJenkins() {
  local crumb
  crumb="$(getCrumb || true)"
  curl -sfLI -X POST "http://${HOST}:${PORT}/quietDown" \
    "${AUTH_CURL[@]}" \
    ${crumb:+-H "$crumb"} \
    || true
}

countRunningJobs() {
  # returns a number (defaults to 0 on error)
  curl -sf "http://${HOST}:${PORT}/computer/api/json" \
    "${AUTH_CURL[@]}" 2>/dev/null \
    | jq -r '.busyExecutors' 2>/dev/null || echo 0
}

waitForFinishOfActiveJobs() {
  suspendJenkins
  local count
  count="$(countRunningJobs || echo 0)"
  while [ "${count}" -gt 0 ]; do
    echo "Active jobs count: ${count}"
    sleep 1
    count="$(countRunningJobs || echo 0)"
  done
  echo "No running jobs. Exiting..."
}

waitForJenkinsToStart() {
  local code=000
  local url="http://${HOST}:${PORT}/login"   # safe endpoint under SSO

  echo "Waiting for Jenkins HTTP on ${url} (accept 200/3xx/401/403)..."
  until code="$(curl -sS -o /dev/null -w '%{http_code}' -I "$url" || echo 000)"; \
        [[ "$code" == "200" || "$code" == "401" || "$code" == "403" || \
           "$code" == "301" || "$code" == "302" || "$code" == "303" || \
           "$code" == "307" || "$code" == "308" ]]; do
    sleep 1
  done
  echo "Jenkins responded with HTTP ${code} — proceeding."
}

waitForGroovyBootstrap() {
  echo "Waiting for Groovy bootstrap marker: ${MARKER_FILE}"
  local waited=0
  local timeout="${WAIT_TIMEOUT:-300}" # seconds; set 0 to disable
  until [ -f "${MARKER_FILE}" ]; do
    sleep 1
    waited=$((waited+1))
    if [ "${timeout}" -gt 0 ] && [ "${waited}" -ge "${timeout}" ]; then
      echo "ERROR: Timed out waiting for ${MARKER_FILE}"
      exit 1
    fi
  done
  echo "Groovy bootstrap complete."

  # Discover token file if username wasn't set
  if [ -z "${SPRYKER_SCHEDULER_USER}" ]; then
    TOKEN_FILE="$(find "${BOOTSTRAP_DIR}" -maxdepth 1 -type f -name '*.token' | head -n1 || true)"
    if [ -z "${TOKEN_FILE}" ]; then
      echo "ERROR: No token file found in ${BOOTSTRAP_DIR}"
      exit 1
    fi
    SPRYKER_SCHEDULER_USER="$(basename "${TOKEN_FILE}")"
    SPRYKER_SCHEDULER_USER="${SPRYKER_SCHEDULER_USER%.token}"
  fi
}

readToken() {
  if [ ! -f "${TOKEN_FILE}" ]; then
    echo "ERROR: Token file not found: ${TOKEN_FILE}"
    exit 1
  fi
  TOKEN_VALUE="$(awk -F'=' '/^tokenValue=/{print $2; exit}' "${TOKEN_FILE}")"
  if [ -z "${TOKEN_VALUE:-}" ]; then
    echo "ERROR: tokenValue not present in ${TOKEN_FILE}"
    exit 1
  fi
  echo "Token for user ${SPRYKER_SCHEDULER_USER} loaded from ${TOKEN_FILE}"

  # Prepare auth array for curl
  local auth_b64
  auth_b64="$(printf '%s' "${SPRYKER_SCHEDULER_USER}:${TOKEN_VALUE}" | base64)"
  AUTH_CURL=(-H "Authorization: Basic ${auth_b64}")
}

# === main bootstrap ===
mkdir -p ~/.jenkins/updates
rm -rf ~/.jenkins/plugins || echo 'plugins did not exist anyway'
mkdir -p ~/.jenkins/plugins
test -f ~/.jenkins/jenkins.model.JenkinsLocationConfiguration.xml || envsubst < /opt/jenkins.model.JenkinsLocationConfiguration.xml > ~/.jenkins/jenkins.model.JenkinsLocationConfiguration.xml

# On shutdown: drain queue then stop Jenkins
trap 'waitForFinishOfActiveJobs; kill ${pid}; exit 0;' SIGTERM

# Seed plugins from ref
cp -r /usr/share/jenkins/ref/plugins/* /root/.jenkins/plugins/ || true

# Init bootstrap script
HOME_DIR="${JENKINS_HOME:-/root/.jenkins}"
INIT_REF="/usr/share/jenkins/ref/init.groovy.d"
INIT_HOME="${HOME_DIR}/init.groovy.d"

mkdir -p "${INIT_HOME}"
if [ -d "${INIT_REF}" ]; then
  # copy only if there are .groovy files; avoid failing when none exist
  if find "${INIT_REF}" -maxdepth 1 -type f -name '*.groovy' | read _; then
    find "${INIT_REF}" -maxdepth 1 -type f -name '*.groovy' -print -exec cp -f {} "${INIT_HOME}/" \;
  fi
fi
echo "Init scripts in HOME (${INIT_HOME}):"
ls -l "${INIT_HOME}" || true

# Start Jenkins (Groovy init runs now and creates the token)
java ${JAVA_OPTS:-} -Djenkins.install.runSetupWizard=false -jar /usr/share/jenkins/jenkins.war ${JENKINS_OPTS:-} & pid=$!

# First wait: HTTP up (no auth yet)
waitForJenkinsToStart
echo "HTTP port ${PORT} on ${HOST} all started up.."

# Wait for Groovy to finish and write the marker + token
waitForGroovyBootstrap
readToken

# Keep PID 1 alive
wait "${pid}"
