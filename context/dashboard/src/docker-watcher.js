#!/usr/bin/env node

const Dockerode = require('dockerode');
const {EventEmitter} = require('events');

const DockerWatcher = function (filters, filterCallback, timeout) {

    const dockerode = new Dockerode();
    const eventEmitter = new EventEmitter();
    const activeContainers = new Map();

    const start = function (container) {
        const containerData = {
            transfer: {
                id: container.Id,
                image: container.Image,
                name: container.Names[0].replace(/^\//, ''),
                labels: container.Labels
            },
            container: dockerode.getContainer(container.Id),
        };
        activeContainers.set(container.Id, containerData);
        eventEmitter.emit('start', containerData.transfer, containerData.container);
    };

    const stop = function (containerId) {
        const containerData = activeContainers.get(containerId);
        activeContainers.delete(containerId);
        eventEmitter.emit('stop', containerData.transfer,  containerData.container);
    };

    const updateContainers = async function () {
        const containers = await dockerode.listContainers({
            filters,
        });

        const activeIds = new Set();

        containers.forEach((container) => {
            if (!filterCallback(container)) {
                return;
            }
            activeIds.add(container.Id)
            if (!activeContainers.has(container.Id)) {
                start(container);
            }
        });

        activeContainers.forEach((containerData, containerId) => {
            if (!activeIds.has(containerId)) {
                stop(containerId)
            }
        });
    }

    setInterval(updateContainers, timeout || 10000);

    updateContainers();

    return eventEmitter;
};

module.exports = DockerWatcher;
