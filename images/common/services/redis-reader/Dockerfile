FROM node:alpine3.15 AS redis-reader-daemon

ENV PORT=3000
ENV REDIS_HOST='127.0.0.1'
ENV REDIS_PORT=6379
ENV REDIS_DB=0

RUN git clone https://github.com/zyuzka/redis-reader.git /redis-reader-daemon

WORKDIR /redis-reader-daemon

RUN npm install

ENTRYPOINT ["node", "app.js"]
