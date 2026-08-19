#!/usr/bin/env bash

require find sort awk tr grep cat

# Host directory where additional trusted root CA certificates are dropped, e.g. a corporate
# TLS-inspection root such as Zscaler. Not to be confused with `~/.spryker/certs`, which holds a
# CA *signing pair* (certificate + private key) used to sign the local website certificate.
readonly CA_CERTIFICATES_HOST_DIR="${HOME}/.spryker/ca-certificates"

# Name of the directory created inside the build contexts that need the certificates.
readonly CA_CERTIFICATES_DIR_NAME="ca-certificates"

# Populated by Environment::CaCertificates::stage().
CA_CERTIFICATES_SOURCE=""
CA_CERTIFICATES_COUNT=0
CA_CERTIFICATES_DIGEST=""
CA_CERTIFICATES_ANNOUNCED=""

# ------------------
# Copies every certificate found on the host into each of the given build-context directories, as
# `certs/` holding one certificate per file and `bundle.crt` holding all of them concatenated. Both
# are always created - empty when the user supplied nothing - so the Dockerfiles can COPY them
# unconditionally. Each target always ends up holding exactly the current set of certificates, so
# removing a certificate on the host removes it from the next build too.
function Environment::CaCertificates::stage() {
    local targetDir
    local scratchDir="${SOURCE_DIR}/deployment/_ca_certificates"

    Environment::CaCertificates::_resolveSource
    Environment::CaCertificates::_collect "${scratchDir}"

    for targetDir in "${@}"; do
        mkdir -p "${targetDir}/certs"
        find "${targetDir}/certs" -maxdepth 1 -type f -name '*.crt' -delete
        : >"${targetDir}/bundle.crt"
        if [ "${CA_CERTIFICATES_COUNT}" -gt 0 ]; then
            cp "${scratchDir}"/*.crt "${targetDir}/certs/"
            cat "${scratchDir}"/*.crt >"${targetDir}/bundle.crt"
        fi
    done

    rm -rf "${scratchDir}"

    if [ "${CA_CERTIFICATES_COUNT}" -gt 0 ] && [ -z "${CA_CERTIFICATES_ANNOUNCED}" ]; then
        CA_CERTIFICATES_ANNOUNCED=1
        Console::info "Trusting ${CA_CERTIFICATES_COUNT} extra CA certificate(s) from ${CA_CERTIFICATES_SOURCE}"
    fi

    return "${TRUE}"
}

# ------------------
# Resolves the certificates without staging them, so that their digest can take part in deciding
# whether a bootstrap may be skipped.
function Environment::CaCertificates::calculate() {
    local scratchDir="${SOURCE_DIR}/deployment/_ca_certificates"

    Environment::CaCertificates::_resolveSource
    Environment::CaCertificates::_collect "${scratchDir}"

    rm -rf "${scratchDir}"

    return "${TRUE}"
}

# ------------------
# Removes previously staged certificates from a generated deployment so that a certificate deleted
# on the host does not survive there. `Command::bootstrap::_deploy` only overlays the new files.
function Environment::CaCertificates::purge() {
    local targetDir=${1}

    [ -z "${targetDir}" ] && return "${TRUE}"

    rm -rf "${targetDir:?}/${CA_CERTIFICATES_DIR_NAME}"

    return "${TRUE}"
}

# ------------------
function Environment::CaCertificates::_resolveSource() {
    CA_CERTIFICATES_SOURCE=""

    if [ -n "${SPRYKER_EXTRA_CA_CERTS}" ]; then
        if [ ! -e "${SPRYKER_EXTRA_CA_CERTS}" ]; then
            Console::error "SPRYKER_EXTRA_CA_CERTS points to \"${SPRYKER_EXTRA_CA_CERTS}\", which does not exist."
            exit 1
        fi
        CA_CERTIFICATES_SOURCE="${SPRYKER_EXTRA_CA_CERTS}"

        return "${TRUE}"
    fi

    mkdir -p "${CA_CERTIFICATES_HOST_DIR}"
    CA_CERTIFICATES_SOURCE="${CA_CERTIFICATES_HOST_DIR}"

    return "${TRUE}"
}

# ------------------
# Normalises every source file into one certificate per file inside ${scratchDir}. Bundles holding
# several certificates are split so that the hash-based lookups of `update-ca-certificates` resolve
# all of them, and so that concatenation cannot break on a missing trailing newline.
function Environment::CaCertificates::_collect() {
    local scratchDir=${1}
    local sourceFile
    local prefix
    local index=0

    CA_CERTIFICATES_COUNT=0
    CA_CERTIFICATES_DIGEST=""

    rm -rf "${scratchDir}"
    mkdir -p "${scratchDir}"

    while IFS= read -r sourceFile; do
        [ -z "${sourceFile}" ] && continue

        if LC_ALL=C grep -q 'PRIVATE KEY' "${sourceFile}"; then
            Console::error "Refusing to read \"${sourceFile}\": it contains a private key."
            Console::error "Only certificates belong in ${CA_CERTIFICATES_SOURCE}. A CA signing pair goes into ${HOME}/.spryker/certs instead."
            exit 1
        fi

        index=$((index + 1))
        prefix="$(basename "${sourceFile}")"
        prefix="$(printf '%03d-%s' "${index}" "$(echo -n "${prefix%.*}" | LC_ALL=C tr -c '[:alnum:]._-' '-')")"

        if LC_ALL=C grep -q -- '-----BEGIN CERTIFICATE-----' "${sourceFile}"; then
            # `close()` is mandatory: the awk shipped with macOS keeps very few files open at once.
            LC_ALL=C tr -d '\r' <"${sourceFile}" | awk -v out="${scratchDir}" -v prefix="${prefix}" '
                /-----BEGIN CERTIFICATE-----/ { number++; output = sprintf("%s/%s.%03d.crt", out, prefix, number) }
                output != "" { print > output }
                /-----END CERTIFICATE-----/ { if (output != "") { close(output); output = "" } }
            '
            continue
        fi

        # Not PEM - most likely DER, which is what macOS Keychain exports by default.
        if command -v openssl >/dev/null 2>&1 &&
            openssl x509 -inform DER -in "${sourceFile}" -out "${scratchDir}/${prefix}.001.crt" 2>/dev/null; then
            continue
        fi

        rm -f "${scratchDir}/${prefix}.001.crt"
        Console::error "Cannot read \"${sourceFile}\" as a PEM or DER certificate."
        Console::error "Convert it first: ${INFO}openssl x509 -inform DER -in \"${sourceFile}\" -out \"${sourceFile%.*}.crt\"${NC}"
        exit 1
    done < <(Environment::CaCertificates::_listSourceFiles)

    CA_CERTIFICATES_COUNT=$(find "${scratchDir}" -maxdepth 1 -type f -name '*.crt' | wc -l | tr -d '[:space:]')
    CA_CERTIFICATES_DIGEST=$(Environment::CaCertificates::_digest "${scratchDir}")

    return "${TRUE}"
}

# ------------------
function Environment::CaCertificates::_listSourceFiles() {
    if [ -f "${CA_CERTIFICATES_SOURCE}" ]; then
        echo "${CA_CERTIFICATES_SOURCE}"

        return "${TRUE}"
    fi

    LC_ALL=C find -L "${CA_CERTIFICATES_SOURCE}" -maxdepth 1 -type f \
        \( -name '*.crt' -o -name '*.pem' -o -name '*.cer' \) 2>/dev/null | LC_ALL=C sort

    return "${TRUE}"
}

# ------------------
function Environment::CaCertificates::_digest() {
    local scratchDir=${1}
    local hashCommand='cksum'

    if command -v shasum >/dev/null 2>&1; then
        hashCommand='shasum -a 256'
    elif command -v sha256sum >/dev/null 2>&1; then
        hashCommand='sha256sum'
    fi

    LC_ALL=C find "${scratchDir}" -maxdepth 1 -type f -name '*.crt' | LC_ALL=C sort |
        xargs cat 2>/dev/null | ${hashCommand} | awk '{print $1}'

    return "${TRUE}"
}
