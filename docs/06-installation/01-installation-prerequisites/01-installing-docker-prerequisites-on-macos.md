# Installing Docker prerequisites on MacOS

This article describes Docker installation prerequisites for MacOS.


## Minimum system requirements

Review the minimum system requirements in the table:

| System Requirement | Additional Details |
| --- | --- |
| vCPU: 2 | This is a minimum requirement. The value can be higher than 2. A lower value is not sufficient for running the application. |
| RAM: 4GB | This is a minimum requirement. The value can be higher than 4GB. A lower value is not sufficient for installation purposes. |
| Swap: 2GB | This is a minimum requirement. The value can be higher than 2GB. A lower value is not sufficient for installation purposes. |

## Install and configure a Docker manager

You can run Spryker in Docker using Docker Desktop or OrbStack. Docker Desktop is a free default tool, but OrbStack works faster with intel-based Macs. 


### Install Docker Desktop

1. Download and install [Docker Desktop (Mac)](https://docs.docker.com/desktop/mac/install/).

{% info_block infoBox %}

Signup for Docker Hub is not required.

{% endinfo_block %}

2. Accept the privilege escalation request "Docker Desktop needs privileged access.".

3. In the Docker Desktop, go to preferences by selecting the gear in the top right corner.

4. In the **General** section of **Preferences**, click the **Use Docker Compose V2** checkbox.

5. Set recommended memory and swap limits:

    1. Go to **Resources** > **ADVANCED**.
    2. Set **CPUs:** to "4" or higher.
    3. Set **Memory:** to "4.00 GB" or higher.
    4. Set **Swap:** to "2.00 GB" or higher.
    5. Set the desired **Disk image size:**.
    6. Select the desired **Disk image location**.
    7. Select **Apply & Restart**.

### Install OrbStack

Download and install [OrbStack](https://orbstack.dev/download).


To migrate from Docker Desktop to OrbStack, see [Migrate from Docker to OrbStack](https://docs.orbstack.dev/install#docker-migration).
To run Docker Desktop and OrbStack side-by-side and switch between them, see [Side-by-side
](https://docs.orbstack.dev/install#docker-context).

## Install Mutagen for development mode

If you are going to run Spryker in [development mode](/docs/scos/dev/set-up-spryker-locally/install-spryker/install/choose-an-installation-mode.html#development-mode), install or update Mutagen and Mutagen Compose to the latest version:

```bash
brew list | grep mutagen | xargs brew remove && brew install mutagen-io/mutagen/mutagen mutagen-io/mutagen/mutagen-compose && mutagen daemon stop && mutagen daemon start
```

## Next steps

See [Chossing an installation mode](../02-installation-guides/01-choosing-an-installation-mode.md) to choose an installation mode.
If you've already selected an installation mode, follow one of the guides below:
* [Installing in Development mode on MacOS and Linux](../02-installation-guides/02-installing-in-development-mode-on-macos-and-linux.md)
* [Installing in Demo mode on MacOS and Linux](../02-installation-guides/04-installing-in-demo-mode-on-macos-and-linux.md)
* [Integrating the Docker SDK into existing projects](../02-installation-guides/06-integrating-the-docker-sdk-into-existing-projects.md)
* [Running production](../02-installation-guides/07-running-production.md)
