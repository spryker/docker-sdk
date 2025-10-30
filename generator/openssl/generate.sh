#!/usr/bin/env bash
set -e
id
export ALT_NAMES=$(printf "DNS:%s" "${@/%/,}" | sed -r "s/,$//g")
SOURCE="${BASH_SOURCE%/*}"

if [ -f "${SOURCE}/default.key" ] && [ -f "${SOURCE}/default.crt" ];
then
    echo -e "Taking predefined CA certificate"
    cp "${SOURCE}/default.key" "${DESTINATION}/ca.key"
    cp "${SOURCE}/default.crt" "${DESTINATION}/ca.crt"
else
    echo -e "Generating CA cert and private key"
    openssl req -nodes -newkey rsa:2048 -out "${DESTINATION}/ca.csr" -keyout "${DESTINATION}/ca.key" -subj "/C=DE/ST=Berlin/L=Berlin/O=Spryker/CN=Spryker"
    openssl x509 -req -days 9999 -in "${DESTINATION}/ca.csr" -signkey "${DESTINATION}/ca.key" -out "${DESTINATION}/ca.crt"
fi

echo -e "Generating PFX file for CA to import on client side"
openssl pkcs12 \
    -export \
    -out "${DESTINATION}/ca.pfx" \
    -inkey "${DESTINATION}/ca.key" \
    -in "${DESTINATION}/ca.crt" \
    -password "pass:${PFX_PASSWORD}"

openssl req \
    -nodes \
    -newkey rsa:2048 \
    -out "${DESTINATION}/ssl.csr" \
    -keyout "${DESTINATION}/ssl.key" \
    -new \
    -sha256 \
    -extensions v3_req \
    -config <( cat "${SOURCE}/v3.ext" )

openssl x509 \
    -CA "${DESTINATION}/ca.crt" \
    -CAkey "${DESTINATION}/ca.key" \
    -CAcreateserial \
    -req \
    -days 365 \
    -in "${DESTINATION}/ssl.csr" \
    -out "${DESTINATION}/ssl.crt" \
    -extfile "${SOURCE}/v3.ext" \
    -extensions v3_req

cat "${DESTINATION}/ca.crt" >> "${DESTINATION}/ssl.crt"

echo -e "Checking certificate chain"
openssl verify \
    -verbose \
    -CAfile "${DESTINATION}/ca.crt" \
    "${DESTINATION}/ssl.crt"

cp "${DESTINATION}/ca.crt" "${DEPLOYMENT_DIR}/spryker_ca.crt"
cp "${DESTINATION}/ca.pfx" "${DEPLOYMENT_DIR}/spryker.pfx"
