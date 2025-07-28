ARG SPRYKER_DASHBOARD_IMAGE=node:alpine

FROM ${SPRYKER_DASHBOARD_IMAGE} AS dashboard

RUN sed -i 's/https:\/\/dl-cdn.alpinelinux.org/http:\/\/dl-cdn.alpinelinux.org/g' /etc/apk/repositories \
    && apk add --no-cache ca-certificates \
    && sed -i 's/http:\/\/dl-cdn.alpinelinux.org/https:\/\/dl-cdn.alpinelinux.org/g' /etc/apk/repositories
WORKDIR /data
COPY certs-system.crt "/usr/local/share/ca-certificates/host-certs.crt"
RUN update-ca-certificates

RUN mkdir -p /dashboard
WORKDIR /dashboard
ENV HOME=/dashboard
ENV NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/host-certs.crt
RUN npm config set cafile /usr/local/share/ca-certificates/host-certs.crt
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
