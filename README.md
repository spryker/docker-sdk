# Spryker Commerce OS — Docker SDK

## Description

Spryker Docker SDK helps to set up a Docker environment for your Spryker project.

This repository does not contain a specific Dockerfile or Docker Compose files. It contains a tool that prepares those files to match the infrastructure of your Spryker project.


Spryker Docker SDK reads a [Deploy file](docs/07-deploy-file/02-deploy.file.reference.v1.md) and builds a production-like Docker infrastructure for Spryker accordingly.

The tool is used for:

1. Building production-like Docker images.
1. Serving as a part of development environment based on Docker.
1. Simplifying the process of setting up a local demo of Spryker project.

## Installing Spryker Docker SDK
> Note: Run all the commands below from the root directory of your Spryker project.

To install the Docker SDK:

1. Fetch Docker SDK tools:
```bash
git clone https://github.com/spryker/docker-sdk.git ./docker
```

> Verification: Make sure `docker 18.09.1+` and `docker-compose 1.23+` have been installed.


2. Initialize Docker setup:

```bash
docker/sdk bootstrap
```

3. Build and run Spryker applications:
```
docker/sdk up
```

## Troubleshooting installation

For installation troubleshooting, see [Troubleshooting installation](docs/09-troubleshooting.md#troubleshooting-installation)

## Documentation

To start working with Spryker in Docker, see [Quick start guide](docs/01-quick-start-guide.md).

## Contributing to Spryker Docker SDK

For contribution guidelines, see [Code contribution guide](https://docs.spryker.com/docs/scos/dev/code-contribution-guide.html)

# Supported Services

This document outlines the services supported by our platform, including engine, version, ARM architecture support, and SSL/TLS support.

## Services Table

| Service               | Engine          | Version(s) | ARM support | SSL | Note                                                                     |
| --------------------- | --------------- | ---------- | ----------- |     | ------------------------------------------------------------------------ |
| **database**          | postgres        | 9.6\*      | ✔           |     |                                                                          |
|                       |                 | 10         | ✔           |     |                                                                          |
|                       |                 | 11         | ✔           |     |                                                                          |
|                       |                 | 12         | ✔           |     |                                                                          |
|                       |                 | 17         | ✔           |     |                                                                          |
|                       | mysql           | 5.7        |             |     |                                                                          |
|                       | mariadb         | 10.2       | ✔           | ✔   | [https://endoflife.date/mariadb](https://endoflife.date/mariadb)         |
|                       |                 | 10.3       | ✔           | ✔   | [https://endoflife.date/mariadb](https://endoflife.date/mariadb)         |
|                       |                 | 10.4       | ✔           | ✔   |                                                                          |
|                       |                 | 10.5       | ✔           | ✔   |                                                                          |
|                       |                 | 10.6       | ✔           | ✔   |                                                                          |
|                       |                 | 10.11      | ✔           | ✔   |                                                                          |
| **broker**            | rabbitmq        | 3.7        |             |     |                                                                          |
|                       |                 | 3.8        | ✔           |     |                                                                          |
|                       |                 | 3.9        | ✔           |     |                                                                          |
|                       |                 | 3.10       | ✔           |     |                                                                          |
|                       |                 | 3.11       | ✔           |     |                                                                          |
|                       |                 | 3.12       | ✔           |     |                                                                          |
|                       |                 | 3.13       | ✔           |     |                                                                          |
| **session**           | redis           | 5.0\*      | ✔           |     |                                                                          |
|                       | redis           | 6.2        | ✔           | ✔   |                                                                          |
|                       | valkey          | 7.2        | ✔           | ✔   |                                                                          |
| **key\_value\_store** | redis           | 5.0\*      | ✔           |     |                                                                          |
|                       | redis           | 6.2        | ✔           | ✔   |                                                                          |
|                       | valkey          | 7.2        | ✔           | ✔   |                                                                          |
| **search**            | elastic         | 5.6\*      | ✔           |     | [https://www.elastic.co/support/eol](https://www.elastic.co/support/eol) |
|                       |                 | 6.8        | ✔           |     | [https://www.elastic.co/support/eol](https://www.elastic.co/support/eol) |
|                       |                 | 7.6        | ✔           |     |                                                                          |
|                       |                 | 7.10       | ✔           | ✔   |                                                                          |
|                       | opensearch      | 1.3        | ✔           | ✔   |                                                                          |
| **scheduler**         | jenkins         | 2.176      |             |     |                                                                          |
|                       |                 | 2.305      | ✔           |     |                                                                          |
|                       |                 | 2.324      | ✔           |     |                                                                          |
|                       |                 | 2.401      | ✔           |     |                                                                          |
|                       |                 | 2.442      | ✔           |     |                                                                          |
|                       |                 | 2.488      | ✔           |     |                                                                          |
|                       |                 | 2.492.3    | ✔           |     |                                                                          |
| **webdriver**         | phantomjs       | latest\*   |             |     |                                                                          |
|                       | chromedriver    | latest     | ✔           |     |                                                                          |
| **mail\_catcher**     | mailhog         | 1.0        | ✔           |     |                                                                          |
|                       | mailpit         | 1.22       | ✔           |     |                                                                          |
|                       |                 | latest     | ✔           |     |                                                                          |
| **swagger**           | swagger-ui      | v3.24      | ✔           |     |                                                                          |
| **kibana**            | kibana          | 5.6\*      | ✔           |     | [https://www.elastic.co/support/eol](https://www.elastic.co/support/eol) |
|                       |                 | 6.8        | ✔           |     | [https://www.elastic.co/support/eol](https://www.elastic.co/support/eol) |
|                       |                 | 7.6        | ✔           |     |                                                                          |
| **redis-gui**         | redis-commander | 0.8.0\*    | ✔           |     |                                                                          |
|                       |                 | 0.9.0      | ✔           |     |                                                                          |
| **blackfire**         | blackfire       | latest     | ✔           |     |                                                                          |

