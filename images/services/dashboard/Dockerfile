FROM node:alpine AS dashboard
LABEL "spryker.image" "dashboard"

WORKDIR /dashboard
ENV HOME=/dashboard

COPY context/dashboard/package.json context/dashboard/package-lock.json /dashboard/

RUN <<EOT
  set -e
  npm install log.io pm2 -g
  npm install
EOT

COPY context/dashboard/ /dashboard

EXPOSE 3000 6689

CMD ["pm2-runtime", "process.yml"]
