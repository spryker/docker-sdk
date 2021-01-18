
This article describes Docker installation prerequisites for Windows.

@(Warning)()(When running commands described in this document, use absolute paths. For example: `mkdir /d/spryker && cd $_` or `mkdir /c/Users/spryker && cd $_`.)

## Minimum system requirements

Review the minimum system requirements in the table:

| System Requirement | Additional Details |
| --- | --- |
| Windows 10 64bit | Pro, Enterprise, or Education (1607 Anniversary Update, Build 14393 or later). |
| BIOS Virtualization is enabled | Typically, virtualization is enabled by default. Note that having the virtualization enabled is different from having Hyper-V enabled. This setting can be checked in the **Task Manager** → **Performance** tab.  For more details, see [Virtualization must be enabled](https://docs.docker.com/docker-for-windows/troubleshoot/#virtualization-must-be-enabled). |
| CPU SLAT-capable feature | SLAT is CPU related feature. It is called Rapid Virtualization Indexing (RVI). |
| RAM: 4GB | This is a minimum requirement. The value can be higher than 4GB. A lower value is not sufficient for installation purposes. |
| vCPU: 2 | This is a minimum requirement. The value can be higher than 2. A lower value is not sufficient for running the application. |

## Installing and configuring the required software

Follow the steps below to install and configure the required software.

1. [Enable WSL2 and install Docker Desktop](https://docs.docker.com/docker-for-windows/wsl/).

2. Install Ubuntu 20.04.

3. Run Ubuntu and update it:

```bash
sudo apt update && sudo apt dist-upgrade
```

4. Exit Ubuntu and restart Windows.


You've installed and configured the required software.



## Next steps

See [Chossing an installation mode](../02-installation-guides/01-choosing-an-installation-mode.md) to choose an installation mode.
If you've already selected an installation mode, follow one of the guides below:
* [Installing in Development mode](../02-installation-guides/02-installing-in-development-mode.md)
* [Installing in Demo mode](../02-installation-guides/03-installing-in-demo-mode.md)
* [Integrating the Docker SDK into existing projects](../02-installation-guides/04-integrating-the-docker-sdk-into-existing-projects.md)
* [Running production](../02-installation-guides/05-running-production.md)
