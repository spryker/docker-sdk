This article describes Docker installation prerequisites for MacOS.


## Minimum System Requirements

Review the minimum system requirements in the table:

| System Requirement | Additional Details |
| --- | --- |
| vCPU: 2 | This is a minimum requirement. The value can be higher than 2. A lower value is not sufficient for running the application. |
| RAM: 4GB | This is a minimum requirement. The value can be higher than 4GB. A lower value is not sufficient for installation purposes. |
| Swap: 2GB | This is a minimum requirement. The value can be higher than 2GB. A lower value is not sufficient for installation purposes. |


## Required Software and Configuration
Follow the steps to install and configure the required software:
1. Download and install [Docker Desktop (Mac)](https://download.docker.com/mac/stable/Docker.dmg).
2. Accept the privilege escalation request "Docker Desktop needs privileged access.".
@(Info)()(Signup for Docker Hub is not required.)

3. Go to ![whale](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Docker+Install+Prerequisites+-+MacOS/whale-x.png) → **Preferences**  → **Command Line** and **Enable experimental features**.


4. Update Memory and Swap Limits:

    1. Go to![whale](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Docker+Install+Prerequisites+-+MacOS/whale-x.png) → **Preferences**  → **Resources** → **ADVANCED**.
    2. Set **CPUs:** to "4" or higher.
    3. Set **Memory:** to "4.00 GB" or higher.
    4. Set **Swap:** to "2.00 GB" or higher.
    5. Set the desired **Disk image size:**.
    6. Select the desired **Disk image location**.
    7. Click **Apply & Restart**.

@(Warning)()(You can set lower **Memory:** and **Swap:** limit values. However, the default limits won't be sufficient to run the application, so make sure to increase them. )

5. Install or update docker-sync:
```shell
sudo gem install docker-sync
```
@(Info)()(This step is required if you want to run Spryker in [Development mode](https://documentation.spryker.com/docs/modes-overview#development-mode).)

## What's next?
See [Modes Overview](https://documentation.spryker.com/docs/modes-overview) to learn about installation modes of Spryker in Docker.
If you've already selected an installation mode, follow one of the guides below:
* [Installation Guide - Development Mode](https://documentation.spryker.com/docs/installation-guide-development-mode)
* [Installation Guide - Demo Mode](https://documentation.spryker.com/docs/installation-guide-demo-mode)
* [Integrating Docker into Existing Projects](https://documentation.spryker.com/docs/integrating-docker-into-existing-projects)
* [Running Production](https://documentation.spryker.com/docs/running-production)
