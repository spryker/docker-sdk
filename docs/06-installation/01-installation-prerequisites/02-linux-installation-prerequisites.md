This article describes Docker installation prerequisites for Linux.

## Minimum System Requirements

Review the minimum system requirements in the table:

| System Requirement | Additional Details |
| --- | --- |
| vCPU: 2 | This is a minimum requirement. The value can be higher than 2. A lower value is not sufficient for running the application. |
| RAM: 4GB | This is a minimum requirement. The value can be higher than 4GB. A lower value is not sufficient for installation purposes. |
| Swap: 2GB | This is a minimum requirement. The value can be higher than 2GB. A lower value is not sufficient for installation purposes. |

## Required Software and Configuration
Follow the steps to install and configure the required software:
1. Download and install [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/) for Linux.
@(Info)()(Signup for Docker Hub is not required.)
2. Enable BuildKit by creating or updating `/etc/docker/daemon.json`:

```php
{
  ...
  "features" : {
    ...
    "buildkit" : true
  }
}
```
3. Restart Docker:
```shell
/etc/init.d/docker restart
```
4. Install Docker-compose:
```shell
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
5. Apply executable permissions to the binary:
```shell
sudo chmod +x /usr/local/bin/docker-compose
```

## What's next?
See [Modes Overview](https://documentation.spryker.com/docs/modes-overview) to learn about installation modes of Spryker in Docker.
If you've already selected an installation mode, follow one of the guides below:
* [Installation Guide - Development Mode](https://documentation.spryker.com/v4/docs/installation-guide-development-mode)
* [Installation Guide- Demo Mode](https://documentation.spryker.com/v4/docs/installation-guide-demo-mode)
* [Integrating Docker into Existing Projects](https://documentation.spryker.com/v4/docs/integrating-docker-into-existing-projects)
* [Running Production](https://documentation.spryker.com/v4/docs/running-production)
