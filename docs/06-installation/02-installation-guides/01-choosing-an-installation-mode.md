
> Audience:
>
> - Everybody who uses the Docker SDK.
>
> Outcome:
> - You understand the difference between modes and can choose one.



In this section, you can find installation guides for Spryker in Docker. Currently, you can install Spryker in the following ways:
* Install Spryker in Development mode.
* Install Spryker in Demo mode.
* Integrate Docker into an exiting project.
* Generate Docker images and assets for a production environement.


## What installation mode do I choose? 

To check out Spryker features and how Spryker works in general, go with the Demo mode. See [Installing in Demo mode](https://documentation.spryker.com/docs/installing-in-demo-mode) for installation instructions.

To install Spryker with all the tools for developing your project, go with the Development mode. See [Installing in Development mode](https://documentation.spryker.com/docs/installing-in-development-mode) for installation instructions.

If you are already running a Spryker project with another solution like Vagrant, and you want to switch to Docker, see [Integrating Docker into existing projects](https://documentation.spryker.com/docs/integrating-docker-into-existing-projects).

To launch a live Spryker project based on Docker, see [Running production](https://documentation.spryker.com/docs/running-production).

Find more details about each mode below.



## Development mode 
Development mode is a configuration in which Spryker is built and running with development tools and file synchronization. Learn about Development mode below or follow [Installing in Development mode](https://documentation.spryker.com/docs/installation-guide-development-mode) to Install Spryker in this mode.

### Use cases
Develpment mode is used in the following cases:
* To learn how Spryker works.
* To develop a new functionality.
* To debug a functionality.



## Demo mode 
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

## Integrating Docker existing projects

If you are already running a Spryker project based on Development Virtual Machine or any other solution, you can convert it into a Docker based project. 
Learn how to convert a project into a Docker based instance in [Integrating Docker into existing projects](https://documentation.spryker.com/docs/integrating-docker-into-existing-projects).

## Running production 

Currently, there is no installation guide for deploying Spryker in Docker in a production environment. But you can generate the images suitable for a production environment and the archives with assets for each application - Yves, Zed and Glue. 

Learn how to generate Docker images and assets for a production environment in [Running production](https://documentation.spryker.com/docs/running-production).

## Next steps 
Once you've selected and installation mode, follow one of the guides below:
* [Installing in Development mode](https://documentation.spryker.com/docs/installing-in-development-mode)
* [Installing in Demo mode](https://documentation.spryker.com/docs/installing-in-demo-mode)
* [Integrating Docker into existing projects](https://documentation.spryker.com/docs/integrating-docker-into-existing-projects)
* [Running production](https://documentation.spryker.com/docs/running-production)
