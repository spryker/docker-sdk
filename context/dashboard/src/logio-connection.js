#!/usr/bin/env node

const net = require('net');

const LogIoConnection = function (logIoHost, logIoPort) {
    let counter = 0;
    while (true) {
        try {
            counter++;
            const connection = net.createConnection(logIoPort, logIoHost);
            console.log(`[LOGGER] Connected to Log.io tcp://${logIoHost}:${logIoPort}`);
            return connection;
        } catch (error) {
            console.error(`[LOGGER] Cannot connect to Log.io tcp://${logIoHost}:${logIoPort}. Retrying... (${counter})`);
        }
    }
}

module.exports = LogIoConnection;
