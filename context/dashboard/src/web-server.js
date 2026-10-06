#!/usr/bin/env node

const fs = require('fs');
const express = require('express');
const favicon = require('serve-favicon');
const httpProxy = require('http-proxy');

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
    const proxy = httpProxy.createProxyServer({changeOrigin: true});
    proxy.on('error', (err, req, res) => {
        console.error(`[PROXY] ${req.url}: ${err.message}`);
        if (res && typeof res.writeHead === 'function' && !res.headersSent) {
            res.writeHead(504);
            res.end();
        } else if (res && typeof res.destroy === 'function') {
            res.destroy();
        }
    });

    //TODO Make proper mapping to proxy for /static, /manifest.json and /socket.io
    app.use((req, res, next) => {
        if (req.url.startsWith('/logs')) {
            req.url = req.url.replace(/^\/logs\/?/, '/');
            return proxy.web(req, res, {target: logIoUiUrl});
        }
        if (req.url.startsWith('/static') || req.url.startsWith('/manifest.json')) {
            return proxy.web(req, res, {target: logIoUiUrl});
        }
        if (req.url.startsWith('/socket.io')) {
            return proxy.web(req, res, {target: logIoWsUrl});
        }
        next();
    });
    const server = app.listen(3000);
    server.on('upgrade', (req, socket, head) => {
        if (req.url.startsWith('/socket.io')) {
            proxy.ws(req, socket, head, {target: logIoWsUrl});
        }
    });

    return app;
}

module.exports = WebServer;
