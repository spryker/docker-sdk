#!/usr/bin/env node

const DockerWatcher = require("./docker-watcher");
const LogIoConnection = require('./logio-connection');
const DockerLogs = require("./docker-logs");
const FileWatcher = require('./file-watcher');
const WebServer = require('./web-server');

const project = process.env.PROJECT;
const logDirectory = process.env.SPRYKER_LOG_DIRECTORY;
const logIoHost = 'localhost';
const logIoPort = 6689;
const logIoUiPort = 6688;
const filters = {'label': {}};
filters.label[`spryker.project=${project}`] = true;
const filterCallback = function (container) {
    return container.Labels['spryker.app.type'] !== 'hidden';
};

const dockerWatcher = new DockerWatcher(filters, filterCallback, 5000);
const connection = new LogIoConnection(logIoHost, logIoPort);
new DockerLogs(connection, dockerWatcher);
new FileWatcher(connection, 'logs', logDirectory);
new WebServer(logIoHost, logIoUiPort);
