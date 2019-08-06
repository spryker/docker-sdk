# Spryker Commerce OS - Docker SDK
[![Build Status](https://travis-ci.org/spryker/docker-sdk.svg)](https://travis-ci.org/spryker/docker-sdk)

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

Fetch Docker SDK tools:
```bash
git clone https://github.com/spryker/docker-sdk.git ./docker
```

> Note: Make sure `docker 18.09.1+` and `docker-compose 1.23+` are installed in the local environment.

### Preparations on project level

1. Prepare the `deploy.yml` file according to the documentation.
    * Use the `deploy*.yml` mask to find examples in [Spryker Shop Suite](https://github.com/spryker-shop/suite)
1. Prepare configuration based on the environment name defined in `deploy.yml#environment`.
    * Use the `config_default-docker*.php` mask to find examples in [Spryker Shop Suite](https://github.com/spryker-shop/suite/tree/master/config/Shared)
1. Prepare a `docker.yml` installation file.
    * Find an example in [Spryker Shop Suite](https://github.com/spryker-shop/suite/tree/master/config/install/docker.yml).
1. Prepare `.dockerignore` to match the project infrastructure.
    * Find an example in [Spryker Shop Suite](https://github.com/spryker-shop/suite/tree/master/.dockerignore).

## Quick start

1. Initialize docker setup:

```bash
docker/sdk bootstrap
```

2. Build and run Spryker applications:
```
docker/sdk up
```

> Note: Make sure all domains from `deploy.yml` are defined as `127.0.0.1` in the `hosts` on the local environment.

3. Use the domains defined in `deploy.yml` to access the applications.

## Documentation

[Spryker Documentation](https://documentation.spryker.com/installation/spryker_in_docker/docker_sdk/docker-sdk-201907.htm)
