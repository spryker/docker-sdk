This page describes how you can convert a non-Docker based project into a Docker based one. If you want to install Spryker in Docker from scratch, start with [Development Mode](https://documentation.spryker.com/docs/modes-overview#development-mode) or [Demo Mode](https://documentation.spryker.com/docs/modes-overview#demo-mode).

## Prerequisites

To start integrating Docker into your project:

1. Follow the [Docker installation prerequisites](https://documentation.spryker.com/docs/docker-installation-prerequisites).
2. Overview and install the necessary features:

| Name | Version |
| --- | --- |
| [Spryker Core](https://documentation.spryker.com/docs/spryker-core-feature-integration) | master |

## Set up .dockerignore

Create a new `.dockerignore` file to match the project file structure:
```yaml
.git
.idea
node_modules
/vendor
/data
!/data/import
.git*
.unison*
/.nvmrc
/.scrutinizer.yml
/.travis.yml
/newrelic.ini

/docker
!/docker/deployment/
```
See [.dockerignore file](https://docs.docker.com/engine/reference/builder/#dockerignore-file) to learn more about the structure of the file.

## Set up Configuration

Under `config/Shared`, adjust or create a configuration file that depends on the environment name. See  [config_default-docker.php](https://github.com/spryker-shop/b2c-demo-shop/blob/master/config/Shared/config_default-docker.php) as an example.

Make sure to adjust the configuration for each separate store. See [config_default-docker_DE.php](https://github.com/spryker-shop/b2c-demo-shop/blob/master/config/Shared/config_default-docker_DE.php) as an example.

## Set up Deploy File

[Deploy file](https://documentation.spryker.com/docs/deploy-file-reference-10) is a YAML file defining Spryker infrastructure and services for Spryker tools used to deploy Spryker applications in different environments.

It's possible to create an unlimited amount of deployment files with different configuration settings: `deploy.yml` for Demo mode, `deploy.dev.yml` for Development mode.

Set up a deploy file per your infruscturcure requirements using the deploy file examples in the table:

| Development mode | Demo mode |
| --- | --- |
| [B2C Demo Shop deploy file](https://github.com/spryker-shop/b2c-demo-shop/blob/master/deploy.dev.yml) | [B2C Demo Shop deploy file](https://github.com/spryker-shop/b2c-demo-shop/blob/master/deploy.yml) |
| [B2B Demo Shop deploy file](https://github.com/spryker-shop/b2b-demo-shop/blob/master/deploy.dev.yml) | [B2B Demo Shop deploy file](https://github.com/spryker-shop/b2b-demo-shop/blob/master/deploy.yml) |

## Set up Installation Script

Under `config/Shared`, prepare the installation recipe that defines the way Spryker should be installed.

Find installation recipe examples below:
* [B2B Demo Shop installation recipe](https://github.com/spryker-shop/b2b-demo-shop/blob/master/deploy.yml)
* [B2C Demo Shop installation recipe](https://github.com/spryker-shop/b2c-demo-shop/blob/master/deploy.yml)

## Install Docker SDK
Follow the steps to install Docker SDK:
1. Fetch Docker SDK tools:
```bash
git clone https://github.com/spryker/docker-sdk.git ./docker
```
:::(Warning) (Verification)
Make sure `docker 18.09.1+` and `docker-compose 1.23+` are installed:

```bash
$ docker version
$ docker-compose --version
```
:::

2. Initialize docker setup:
 ```bash
docker/sdk bootstrap
```
:::(Info) (Bootstrap)
Once you finish the setup, you don't need to run `bootstrap` to start the instance. Run it only after:
* Docker SDK version update
* Deploy file update
:::
3. Build and run Spryker applications:
```bash
docker/sdk up
```

:::(Warning) ()
Ensure that, in the `hosts` file in the local environment, all the domains from `deploy.yml` are defined as `127.0.0.1`.
:::


## Endpoints

Ensure that you can open the following endpoints:

* yves.de.spryker.local, yves.at.spryker.local, yves.us.spryker.local - Shop UI (*Storefront*)
* zed.de.spryker.local, zed.at.spryker.local, zed.us.spryker.local - Back-office UI (*the Back Office*)
* glue.de.spryker.local, glue.at.spryker.local, glue.us.spryker.local - API endpoints
* scheduler.spryker.local - Jenkins (*scheduler*)
* queue.spryker.local - RabbitMQ UI (*queue*).
@(Info)()(Use "spryker" as a username and "secret" as a password. These credentials are defined and can be changed in `deploy.yml` or `deploy.dev.yml`.)
* mail.spryker.local - Mailhog UI (*email catcher*)

## Useful Commands

Run the `docker/sdk help` command to get the full and up-to-date list of commands.

## What's next?
* [Troubleshooting](https://documentation.spryker.com/docs/spryker-in-docker-troubleshooting)
* [Debugging Setup in Docker](https://documentation.spryker.com/docs/debugging-setup-in-docker)
* [Deploy File Reference - 1.0](https://documentation.spryker.com/docs/deploy-file-reference-10)
* [Services](https://documentation.spryker.com/docs/services)
* [Self-signed SSL Certificate Setup](https://documentation.spryker.com/docs/self-signed-ssl-certificate-setup)
* [Additional DevOPS Guidelines](https://documentation.spryker.com/docs/additional-devops-guidelines)
