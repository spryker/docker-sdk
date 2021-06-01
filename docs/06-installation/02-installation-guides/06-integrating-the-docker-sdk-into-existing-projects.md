# Integrating the Docker SDK into existing projects


This page describes how you can convert a non-Docker based project into a Docker based one. If you want to install Spryker in Docker from scratch, start with [Development Mode](01-choosing-an-installation-mode.md#development-mode) or [Demo Mode](01-choosing-an-installation-mode.md#demo-mode).

## Prerequisites

To start integrating Docker into your project:

1. Follow the one of the Docker installation prerequisites:

* [Installing Docker prerequisites on MacOS](../01-installation-prerequisites/01-installing-docker-prerequisites-on-macos.md)
* [Installing Docker prerequisites on Linux](../01-installation-prerequisites/01-installing-docker-prerequisites-on-linux.md)
* [Installing Docker prerequisites on Windows](../01-installation-prerequisites/01-installing-docker-prerequisites-on-windows.md)
2. Integrate the [Spryker Core](https://documentation.spryker.com/docs/spryker-core-feature-integration) feature into your project.

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

## Set up configuration

In `config/Shared`, adjust or create a configuration file. The name of the file should correspond to your environment. See  [config_default-docker.php](https://github.com/spryker-shop/b2c-demo-shop/blob/master/config/Shared/config_default-docker.php) as an example.

Make sure to adjust the configuration for each separate store. See [config_default-docker_DE.php](https://github.com/spryker-shop/b2c-demo-shop/blob/master/config/Shared/config_default-docker_DE.php) as an example.

## Set up a Deploy file

Set up a [Deploy file](https://documentation.spryker.com/docs/deploy-file-reference-10) per your infruscturcure requirements using the examples in the table:

| Development mode | Demo mode |
| --- | --- |
| [B2C Demo Shop deploy file](https://github.com/spryker-shop/b2c-demo-shop/blob/master/deploy.dev.yml) | [B2C Demo Shop deploy file](https://github.com/spryker-shop/b2c-demo-shop/blob/master/deploy.yml) |
| [B2B Demo Shop deploy file](https://github.com/spryker-shop/b2b-demo-shop/blob/master/deploy.dev.yml) | [B2B Demo Shop deploy file](https://github.com/spryker-shop/b2b-demo-shop/blob/master/deploy.yml) |

## Set up the installation script

In `config/Shared`, prepare the installation recipe that defines the way Spryker should be installed.

Use the following recipe examples:
* [B2B Demo Shop installation recipe](https://github.com/spryker-shop/b2b-demo-shop/blob/master/deploy.yml)
* [B2C Demo Shop installation recipe](https://github.com/spryker-shop/b2c-demo-shop/blob/master/deploy.yml)

## Install the Docker SDK
Follow the steps to install the Docker SDK:
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

To ensure that the installation is successful, make sure you can access the following endpoints.

| Application | Endpoints |
| --- | --- |
| The Storefront |  yves.de.spryker.local, yves.at.spryker.local, yves.us.spryker.local |
| the Back Office | backoffice.de.spryker.local, backoffice.at.spryker.local, backoffice.us.spryker.local |
| Glue API | glue.de.spryker.local, glue.at.spryker.local, glue.us.spryker.local |
| The Merchant Portal | mp.de.spryker.local, mp.at.spryker.local, mp.us.spryker.local |
| Jenkins (scheduler) | scheduler.spryker.local |
| RabbitMQ UI (queue manager) | queue.spryker.local |
| Mailhog UI (email catcher) | mail.spryker.local |

:::(Info) (RabbitMQ UI credentials)
To access RabbitMQ UI, use `spryker` as a username and `secret` as a password. You can adjust the credentials in `deploy.yml`. See [Deploy File Reference - 1.0](https://documentation.spryker.com/docs/deploy-file-reference-10#deploy-file-reference---1-0) to learn about the Deploy file.
:::



## Getting the list of useful commands

To get the full and up-to-date list of commands, run `docker/sdk help`.

## Next steps

* [Troubleshooting](../../troubleshooting.md)
* [Configuring debugging](../../02-development-usage/05-configuring-debugging.md)
* [Deploy File Reference - 1.0](../../99-deploy.file.reference.v1.md)
* [Configuring services](../../06-configuring-services.md)
* [Setting up a self-signed SSL certificate](https://documentation.spryker.com/docs/setting-up-a-self-signed-ssl-certificate)
* [Additional DevOPS guidelines](https://documentation.spryker.com/docs/additional-devops-guidelines)
