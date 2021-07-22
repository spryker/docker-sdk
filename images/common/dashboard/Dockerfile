FROM node:alpine AS dashboard

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
