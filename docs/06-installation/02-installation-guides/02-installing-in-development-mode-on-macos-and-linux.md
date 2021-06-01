# Installing in Development mode on MacOS and Linux

This document describes how to install Spryker in [Development Mode](01-choosing-an-installation-mode.md#development-mode) on MacOS and Linux.

## Installing Docker prerequisites on MacOS and Linux

To install Docker prerequisites, follow one of the guides:
* [Installing Docker prerequisites on MacOS](../01-installation-prerequisites/01-installing-docker-prerequisites-on-macos.md)
* [Installing Docker prerequisites on Linux](../01-installation-prerequisites/01-installing-docker-prerequisites-on-linux.md)




## Installing Spryker in Development mode on MacOS and Linux
Follow the steps to install Spryker in Development mode:


1. Open a terminal.
2. Create a new folder and navigate into it.
3. Depending on the desired [Demo Shop](https://documentation.spryker.com/docs/en/about-spryker#spryker-b2b-b2c-demo-shops):

    a. Clone the B2C repository:

    ```bash
    git clone https://github.com/spryker-shop/b2c-demo-shop.git -b 202009.0-p1 --single-branch ./b2c-demo-shop
    ```

    b. Clone the B2B repository:

    ```bash
    git clone https://github.com/spryker-shop/b2b-demo-shop.git -b 202009.0-p1 --single-branch ./b2b-demo-shop
    ```

4. Depending on the repository you've cloned, navigate into the cloned folder:
    * B2C repository:
    ```bash
    cd b2c-demo-shop
    ```
    * B2B repository:
    ```bash
    cd b2b-demo-shop
    ```
:::(Warning) (Verification)
Make sure that you are in the correct folder by running the `pwd` command.
:::

5. In `deploy.dev.yml`, define `image:` with the PHP image compatible with the current release of the Demo Shop:

```yaml
image: spryker/php:7.3-alpine3.12
```

6. Clone the Docker SDK repository:
```bash
git clone https://github.com/spryker/docker-sdk.git --single-branch docker
```

:::(Warning) (Verification)
Make sure `docker 18.09.1+` and `docker-compose 1.23+` are installed:

```bash
$ docker version
$ docker-compose --version
```
:::

7. Bootstrap local docker setup:
```bash
docker/sdk bootstrap deploy.dev.yml
```
:::(Warning) (Bootstrap)
Once you finish the setup, you don't need to run `bootstrap` to start the instance. You only need to run it after you update the Docker SDK or the deploy file.
:::

8. Once the job finishes, build and start the instance:
```bash
docker/sdk up
```

9. Update the `hosts` file:
```bash
echo "127.0.0.1 backoffice.de.spryker.local backend-gateway.de.spryker.local backend-api.de.spryker.local yves.de.spryker.local glue.de.spryker.local backoffice.at.spryker.local backend-gateway.at.spryker.local backend-api.at.spryker.local yves.at.spryker.local glue.at.spryker.local backoffice.us.spryker.local backend-gateway.us.spryker.local backend-api.us.spryker.local yves.us.spryker.local glue.us.spryker.local mail.spryker.local scheduler.spryker.local queue.spryker.local" | sudo tee -a /etc/hosts
```
@(Info)()(If needed, add corresponding entries for other stores. For example, if you are going to have a US store, add the following entries: `backoffice.us.spryker.local backend-gateway.us.spryker.local backend-api.us.spryker.local glue.us.spryker.local yves.us.spryker.local`)

@(Warning)()(Depending on the hardware performance, the first project launch can take up to 20 minutes.)

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
To access RabbitMQ UI, use `spryker` as a username and `secret` as a password. You can adjust the credentials in `deploy.yml`. See [Deploy file reference - 1.0](../../99-deploy.file.reference.v1.md) to learn about the Deploy file.
:::

## Getting the list of useful commands

To get the full and up-to-date list of commands, run `docker/sdk help`.

## Next steps

* [Troubleshooting](../../troubleshooting.md)
* [Configuring debugging](../../02-development-usage/05-configuring-debugging.md)
* [Deploy file reference - 1.0](../../99-deploy.file.reference.v1.md)
* [Configuring services](../../06-configuring-services.md)
* [Setting up a self-signed SSL certificate](https://documentation.spryker.com/docs/setting-up-a-self-signed-ssl-certificate)
* [Additional DevOPS guidelines](https://documentation.spryker.com/docs/additional-devops-guidelines)
