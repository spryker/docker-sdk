This document is a draft. See [Docker SDK](https://documentation.spryker.com/docs/docker-sdk) for official documentation.

## Description
Read the description below and, in the *Structure* section, fill out the document by answering the questions directly.
We may have added some existing content and encourage you to update, remove or restructure it if needed. 

> Audience:
>
> - Everybody who uses
>
> Outcome:
> - You understand the difference between modes and know what mode to choose in a particular case.

## Outline

1. [Port the existing document]
2. Describe a case when changes in demo mode can be seen in 2 minutes using docker/sdk up. (You would not need dev mode if you only need to make small changes).

## Important points to cover

* Emphasize that demo mode is closer to production one, so it is better to use for QA and demo.
* Dev mode is better to use when changes in the codebase must be seen instantly.


## Structure

:::(Info)(Structure)
The structure below is just a reference. We encourage you to add subsections, change or swap the provided sections if needed.
:::

In this section, you can find installation guides for Spryker in Docker. Spryker provides several installation modes. Currently, you can install Spryker in the following ways:
* Install Spryker in Development mode.
* Install Spryker in Demo mode.
* Integrate Docker into an exiting project.
* Generate Docker images and assets for a production environement.

### Configuration
You can switch between Demo ( `DEMO`) and Development ( `DEV`) modes, but, usually, only one mode is used.

The mode is defined in one of the [Deploy files](https://documentation.spryker.com/docs/deploy-file-reference-10): 
* `deploy.yml` for the `DEMO` mode
*  `deploy.dev.yml` for `DEV` mode

## Development Mode 
Development mode is a configuration in which Spryker is built and running with development tools and file synchronization. Learn about Development mode below or follow [Installing in Development mode](https://documentation.spryker.com/docs/installation-guide-development-mode) to Install Spryker in this mode.

### Use Cases
Develpment mode is used in the following cases:
* To learn how Spryker works.
* To develop a new functionality.
* To debug a functionality.


### File Synchronization
File synchronization is used to test new functionalities without rebuilding Docker containers. File changes are synchronized between Docker containers and the host machine. When containers are killed, all the files remain on the host machine.

You can find file syncronization soulutions for each operating system in the table:

| OS | Solution |
| --- | --- |
| Linux | [bind mount](https://docs.docker.com/storage/bind-mounts/) |
| MacOS | [Mutagen](https://mutagen.io/documentation/introduction) |
| Windows | [docker-sync](https://docker-sync.readthedocs.io/en/latest/) |

### Database Access


In Development mode, you can access your MySQL or MariaDB database using the credentials:

* `host` - `localhost`
* `port` - `3306`
* `user` - `spryker`
* `pw` - `secret`

With a PostgreSQL database, use the following credentials:

* `host` - `localhost`
* `port` - `5432`
* `user` - `spryker`
* `pw` - `secret`

You can change the credentials in the [Deploy file](https://documentation.spryker.com/docs/deploy-file-reference-10).

### Debugging
In Development mode, you can use [Xdebug](https://xdebug.org) for debugging.
Run the command, to enable it:
```bash
docker/sdk {run|start|up} -x
``` 

Find more more information on debugging with Xdebug in [Debugging setup in Docker](https://documentation.spryker.com/docs/debugging-setup-in-docker).


## Demo Mode 
Demo mode is a configuration in which Spryker is built and running without development tools, like file synchronization. As a result, Docker images in this mode are smaller. Learn about Demo mode below or follow [Installing in Demo mode](https://documentation.spryker.com/docs/installation-guide-demo-mode) to Install Spryker in this mode.

In Demo mode, the following functionalities are missing or disabled:
1. [Swagger UI service](https://documentation.spryker.com/docs/services#swagger-ui) - this image is not built, and the container is not running.
2. [Debugging functionality](#debugging) is disabled.
3. [File synchronization](#file-synchronization) is disabled.

### Use Cases
Demo mode is used in the following cases:
* To check or show the functionalities of [[B2B](https://documentation.spryker.com/docs/en/b2b-suite)/[B2C demo shops](https://documentation.spryker.com/docs/en/b2c-suite)].
* To check a custom build or a new feature.
* To test or deploy an application using Continuous Integration and Continuous Delivery tools.

## Integrating Docker Existing Projects

If you are already running a Spryker project based on Development Virtual Machine or any other solution, you can convert it into a Docker based project. 
Learn how to convert a project into a Docker based instance in [Integrating Docker into existing projects](https://documentation.spryker.com/docs/integrating-docker-into-existing-projects).

## Running Production 

Currently, there is no installation guide for deploying Spryker in Docker in a production environment. But you can generate the images suitable for a production environment and the archives with assets for each application - Yves, Zed and Glue. 

Learn how to generate Docker images and assets for a production environment in [Running production](https://documentation.spryker.com/docs/running-production).

**What's next?**
Once you've selected and installation mode, follow one of the guides below:
* [Installing in Development mode](https://documentation.spryker.com/docs/installation-guide-development-mode)
* [Installing in Demo mode](https://documentation.spryker.com/docs/installation-guide-demo-mode)
* [Integrating Docker into existing projects](https://documentation.spryker.com/docs/integrating-docker-into-existing-projects)
* [Running production](https://documentation.spryker.com/docs/running-production)
