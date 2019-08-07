# Spryker Commerce OS - Docker SDK
[![Build Status](https://travis-ci.org/spryker/docker-sdk.svg)](https://travis-ci.org/spryker/docker-sdk)
​
## Description

Spryker Docker SDK helps to setup docker environment for your Spryker project.

This repository does not contain the specific Dockerfile or docker-compose files.
It contains a tool which prepares those files automatically in order to match the infrastructure specific to your Spryker project.

Spryker Docker SDK requires the [Deploy file](https://documentation.spryker.com/installation/spryker_in_docker/docker_sdk/deploy-file-reference-201907.htm).
The tool reads the specified Deploy file and builds a production-like Docker infrastructure for Spryker accordingly.

The purposes of the tool:

1. Building production-ready Docker images.
1. Serving as a part of development environment based on Docker.
1. Simplifying the process of setting up a local demo of Spryker project.

## Installation
> Note: All the commands below should be run from the root directory of Spryker project.

1. Fetch Docker SDK tools:
```bash
git clone https://github.com/spryker/docker-sdk.git ./docker
```

> Note: Make sure `docker 18.09.1+` and `docker-compose 1.23+` are installed in the local environment.

2. Initialize docker setup:

```bash
docker/sdk bootstrap
```

3. Build and run Spryker applications:
```
docker/sdk up
```

> Note: Make sure all domains from `deploy.yml` are defined as `127.0.0.1` in the `hosts` on the local environment.


## Getting Started

To start working with Spryker in Docker, follow [the link]
(https://documentation.spryker.com/installation/spryker_in_docker/docker_sdk/docker-sdk.htm).


## Documentation

[Spryker Docker SDK Documentation](https://documentation.spryker.com/installation/spryker_in_docker/docker_sdk/docker-sdk-201907.htm)
