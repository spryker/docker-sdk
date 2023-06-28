FROM application as application-dev
LABEL "spryker.image" "none"

# Make self-signed certificate to be trusted locally
COPY ${DEPLOYMENT_PATH}/context/nginx/ssl/ca.crt /usr/local/share/ca-certificates
RUN update-ca-certificates
