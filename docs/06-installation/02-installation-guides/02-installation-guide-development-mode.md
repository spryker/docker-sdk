This document describes the procedure of installing Spryker in [Development Mode](https://documentation.spryker.com/docs/modes-overview#development-mode).


:::(Warning) ()
Before you start, make sure to fulfill the [prerequisites](https://documentation.spryker.com/docs/docker-installation-prerequisites).
:::
## Installation
Follow the steps to install Spryker in Development mode:

1. Open a terminal.
@(Info)()(In case you are going to run the script on Windows, open Ubuntu (For more details, see the *Install Docker Desktop* section in [Docker Install Prerequisites - Windows](https://documentation.spryker.com/docs/docker-installation-prerequisites-windows).))
2. Create a new folder and navigate into this folder.
3. Depending on the desired [Demo Shop](https://documentation.spryker.com/docs/en/about-spryker#spryker-b2b-b2c-demo-shops):

    a. Clone the B2C repository:

    ```bash
    git clone https://github.com/spryker-shop/b2c-demo-shop.git -b 202009.0 --single-branch ./
    ```

    b. Clone the B2B repository:

    ```shell
    git clone https://github.com/spryker-shop/b2b-demo-shop.git -b 202009.0 --single-branch ./
    ```

4. Depending on the cloned repository, navigate into the cloned folder:
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

5. In `deploy.dev.yml`, define `image:` with the PHP image compatible with the current release of the demo shop:

```yaml
image: spryker/php:7.3-alpine3.12
```

6. Clone the docker repository:
```shell
git clone https://github.com/spryker/docker-sdk.git --single-branch docker
```

:::(Warning) (Verification)
Make sure `docker 18.09.1+` and `docker-compose 1.23+` are installed:

```bash
$ docker version
$ docker-compose --version
```
:::
6. Bootstrap local docker setup:
```shell
docker/sdk bootstrap deploy.dev.yml
```
:::(Warning) (Bootstrap)
Once you finish the setup, you don't need to run `bootstrap` to start the instance. You only need to run it after:
* Docker SDK version update;
* Deploy file update.
:::
7. Once the job finishes, build and start the instance:
```shell
docker/sdk up
```
8. Update the `hosts` file:

  - Linux/MacOS:				
```shell
echo "127.0.0.1 zed.de.spryker.local yves.de.spryker.local glue.de.spryker.local zed.at.spryker.local yves.at.spryker.local glue.at.spryker.local zed.us.spryker.local yves.us.spryker.local glue.us.spryker.local mail.spryker.local scheduler.spryker.local queue.spryker.local" | sudo tee -a /etc/hosts
```
@(Info)()(If needed, add corresponding entries for other stores. For example, if you are going to have a US store, add the following entries: `zed.us.spryker.local glue.us.spryker.local yves.us.spryker.local`)
  - Windows:
    1. Click **Start** → **Search** and type "Notepad".
    2. Right-click **Notepad** and select the **Run as administrator option**.
    3. In the **User Account Control** window click **Yes** to confirm the action.
    4. In the upper navigation panel, select **File** → **Open**.
    5. Put the following path into the address line: `C:\Windows\System32\drivers\etc`
    6. In the **File name** line, enter "hosts" and click **Open**.
    The hosts file is opened in the drop-down.
    7. Add the following line into the file:
	`127.0.0.1   zed.de.spryker.local glue.de.spryker.local yves.de.spryker.local scheduler.spryker.local mail.spryker.local queue.spryker.local`
    @(Info)()(If needed, add corresponding entries for other stores. For example, if you are going to have a US store, add the following entries: `zed.us.spryker.local glue.us.spryker.local yves.us.spryker.local`)
    9. Click **File** → **Save**.
    10. Close the file.


@(Warning)()(Depending on the hardware performance, the first project launch can take up to 20 minutes.)

## Endpoints

To ensure that the installation is successful, make sure you can open the following endpoints:

* yves.de.spryker.local, yves.at.spryker.local, yves.us.spryker.local - Shop UI (*Storefront*)
* zed.de.spryker.local, zed.at.spryker.local, zed.us.spryker.local - Back-office UI (*the Back Office*)
* glue.de.spryker.local, glue.at.spryker.local, glue.us.spryker.local - API endpoints
* scheduler.spryker.local - Jenkins (*scheduler*)
* queue.spryker.local - RabbitMQ UI (*queue*).
@(Info)()(Use "spryker" as a username and "secret" as a password. These credentials are defined and can be changed in `deploy.dev.yml`.)
* mail.spryker.local - Mailhog UI (*email catcher*)

## Useful Commands

Run the `docker/sdk help` command to get the full and up-to-date list of commands.

## What's next?
* [Troubleshooting](https://documentation.spryker.com/docs/troubleshooting)
* [Debugging Setup in Docker](https://documentation.spryker.com/docs/debugging-setup-in-docker)
* [Deploy File Reference - 1.0](https://documentation.spryker.com/docs/deploy-file-reference-10)
* [Services](https://documentation.spryker.com/docs/services)
* [Self-signed SSL Certificate Setup](https://documentation.spryker.com/docs/self-signed-ssl-certificate-setup)
* [Additional DevOPS Guidelines](https://documentation.spryker.com/docs/additional-devops-guidelines)
