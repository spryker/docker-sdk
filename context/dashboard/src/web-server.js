#!/usr/bin/env node

const fs = require('fs');
const express = require('express');
const favicon = require('serve-favicon');
const {createProxyMiddleware} = require('http-proxy-middleware');

const WebServer = function (logIoHost, logIoUiPort) {

    const app = express();

    app.set('view engine', 'pug')
    app.use('/assets', express.static('assets'))
    app.use(favicon('assets/favicon.ico'));
    app.get('/', function (req, res) {
        res.render('index', JSON.parse(fs.readFileSync('environment/environment.json')));
    })

    const logIoUiUrl = `http://${logIoHost}:${logIoUiPort}`;
    const logIoWsUrl = `ws://${logIoHost}:${logIoUiPort}`;
    const logIoProxyConfig = {
        target: logIoUiUrl,
        changeOrigin: true,
        pathRewrite: {
            '^/logs': '',
        },
    }
    app.use(createProxyMiddleware('/logs', logIoProxyConfig));
    app.use(createProxyMiddleware('/static', logIoProxyConfig)); //TODO Make proper mapping to proxy
    app.use(createProxyMiddleware('/manifest.json', logIoProxyConfig)); //TODO Make proper mapping to proxy
    const wsProxy = createProxyMiddleware('/socket.io', {...logIoProxyConfig, target: logIoWsUrl});  //TODO Make proper mapping to proxy
    app.use(wsProxy);
    const server = app.listen(3000);
    server.on('upgrade', wsProxy.upgrade);

    return app;
}

module.exports = WebServer;
