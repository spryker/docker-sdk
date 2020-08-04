#!/usr/bin/env node

const loghose = require("docker-loghose");
const through = require('through2');

const DockerLogs = function (connection, dockerWatcher) {

    const loghosePipe = loghose({
        json: false,
        docker: null,
        events: dockerWatcher,
        addLabels: true,
    });

    loghosePipe.on('error', console.warn);
    loghosePipe.pipe(through.obj(function (chunk, encoding, callback) {
        this.push('+msg|' + (chunk['spryker.app.type'] || chunk.name) + '|' + (chunk['spryker.app.name'] || chunk.name) + '|' + chunk.line + '\0');
        callback();
    })).pipe(connection);

    dockerWatcher.on('start', function (meta) {
        console.log(`[LOGGER] Container added: ${meta.name}`)
        const labels = meta.labels || {};
        connection.write('+input|' + (labels['spryker.app.type'] || meta.name) + '|' + (labels['spryker.app.name'] || meta.name) + '\0');
    });
    dockerWatcher.on('stop', function (meta) {
        console.log(`[LOGGER] Container removed: ${meta.name}`)
        const labels = meta.labels || {};
        connection.write('-input|' + (labels['spryker.app.type'] || meta.name) + '|' + (labels['spryker.app.name'] || meta.name) + '\0');
    });

    return loghosePipe;
}

module.exports = DockerLogs;
