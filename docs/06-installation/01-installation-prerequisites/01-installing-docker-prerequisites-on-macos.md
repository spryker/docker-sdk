# Installing Docker prerequisites on MacOS

This article describes Docker installation prerequisites for MacOS.


## Minimum system requirements

Review the minimum system requirements in the table:

| System Requirement | Additional Details |
| --- | --- |
| vCPU: 2 | This is a minimum requirement. The value can be higher than 2. A lower value is not sufficient for running the application. |
| RAM: 4GB | This is a minimum requirement. The value can be higher than 4GB. A lower value is not sufficient for installation purposes. |
| Swap: 2GB | This is a minimum requirement. The value can be higher than 2GB. A lower value is not sufficient for installation purposes. |


## Installing and configuring required software
Follow the steps to install and configure the required software:
1. Download and install [Docker Desktop (Mac)](https://desktop.docker.com/mac/stable/amd64/Docker.dmg).
2. Accept the privilege escalation request "Docker Desktop needs privileged access.".
@(Info)()(Signup for Docker Hub is not required.)

3. Go to ![whale](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Docker+Install+Prerequisites+-+MacOS/whale-x.png) > **Preferences**  > **Command Line** and **Enable experimental features**.


4. Update Memory and Swap Limits:

    1. Go to![whale](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Docker+Install+Prerequisites+-+MacOS/whale-x.png) > **Preferences**  > **Resources** > **ADVANCED**.
    2. Set **CPUs:** to "4" or higher.
    3. Set **Memory:** to "4.00 GB" or higher.
    4. Set **Swap:** to "2.00 GB" or higher.
    5. Set the desired **Disk image size:**.
    6. Select the desired **Disk image location**.
    7. Click **Apply & Restart**.

@(Warning)()(You can set lower **Memory:** and **Swap:** limit values. However, the default limits won't be sufficient to run the application, so make sure to increase them. )

5. [Development mode](../02-installation-guides/01-choosing-an-installation-mode.md#development-mode): Install Mutagen:
```shell
brew install mutagen-io/mutagen/mutagen-beta
```

## Next steps

See [Chossing an installation mode](../02-installation-guides/01-choosing-an-installation-mode.md) to choose an installation mode.
If you've already selected an installation mode, follow one of the guides below:
* [Installing in Development mode on MacOS and Linux](../02-installation-guides/02-installing-in-development-mode-on-macos-and-linux.md)
* [Installing in Demo mode on MacOS and Linux](../02-installation-guides/04-installing-in-demo-mode-on-macos-and-linux.md)
* [Integrating the Docker SDK into existing projects](../02-installation-guides/06-integrating-the-docker-sdk-into-existing-projects.md)
* [Running production](../02-installation-guides/07-running-production.md)
