FROM node:22-alpine3.20 AS dashboard

# Trust the extra root CA certificates staged by the SDK, e.g. a corporate TLS-inspection root
# such as Zscaler. NodeJS ignores the operating system trust store, so npm needs this bundle. The
# build argument stays empty unless certificates were staged, and NodeJS ignores an empty value.
COPY context/ca-certificates/bundle.crt /etc/ssl/spryker-extra-ca-certificates.crt
ARG SPRYKER_EXTRA_CA_BUNDLE=
ENV NODE_EXTRA_CA_CERTS=${SPRYKER_EXTRA_CA_BUNDLE}

RUN mkdir -p /dashboard
WORKDIR /dashboard
ENV HOME=/dashboard

RUN npm install log.io pm2 -g

COPY context/dashboard/package.json context/dashboard/package-lock.json /dashboard/
RUN npm install

COPY context/dashboard/.log.io /dashboard/.log.io/
COPY context/dashboard/assets /dashboard/assets/
COPY context/dashboard/src /dashboard/src/
COPY context/dashboard/views /dashboard/views/
COPY context/dashboard/process.yml /dashboard/

EXPOSE 3000 6689

CMD ["pm2-runtime", "process.yml"]
