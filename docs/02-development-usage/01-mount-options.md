This document is a draft. See [Docker SDK](https://documentation.spryker.com/docs/docker-sdk) for official documentation.

## Description
Read the description below and, in the *Structure* section, fill out the document by answering the questions directly.

> Audience:
>
> - Developers who are developing with docker/sdk.
>
> Outcome:
> - You know how to choose a mount mode based on a platform.
> - You understand the specifics of synchronization file mode.

## Outline

1. Short description of every mount mode docker/sdk support.
2. How sync modes work and what their downsides are. Figure: https://spryker.atlassian.net/wiki/spaces/PS/pages/1098088730/Mounting+for+development+in+MacOS+Windows

### Important points to cover

* Description of mount modes should include information on what mode is preferable for what actions and what platform.
* Provide links to the official docs of Docker Desktop and GitHub where file sharing is described.

## Structure

:::(Info)(Structure)
The structure below is just a reference. We encourage you to add subsections, change or swap the provided sections if needed.
:::

### Selecting a mount mode for development

Depending on your operating system (OS), choose one of the mount options in the table.

| Mount option |        MacOS            | Linux              | Windows (WSL1)          | Windows (WSL2)     |
|--------------|-------------------------|--------------------|-------------------------|--------------------|
| native       | :ballot_box_with_check: | :heavy_check_mark: | :ballot_box_with_check: | :heavy_check_mark: |
| mutagen      | :heavy_check_mark:      |                    |                         |                    |
| docker-sync  | :white_check_mark:      |                    | :heavy_check_mark:      |                    |

* (:heavy_check_mark:) - recommended solution
* (:white_check_mark:) - supported solution
* (:ballot_box_with_check:) - supported solution with very slow performance

### Supported mount modes

docker/sdk supports the following mount modes:

* baked
Copies source files into image, so they *cannot* be changed from host machine.
The file or directory is referenced by its absolute path on the host machine.
This mount option is default for the Demo mode.

* native
Mounts source files directly from host machine into containers.
Works perfectly with Linux and Windows (WSL2).

* docker-sync
Synchronizes source files from host machine into running containers.
This mount option is stable with MacOS and Windows (WSL1).

* mutagen
Synchronizes source files between your host machine and a container in an effective real-time way that combines the performance of the rsync algorithm with bidirectionality and low-latency filesystem watching.
This mount option is stable with MacOS.

### Changing a mount mode

To change a mount mode, in `deploy.*.yaml`, define your OS for the desired mount mode:

```yaml
docker:

...

    mount:
        native:
            platforms:
                - linux

        docker-sync:
            platforms:
                - windows

        mutagen:
            platforms:
                - macos
```

:::(Info)(Multiple mount modes)
If the same OS is defined for multiple mount modes, the first mount mode matching the OS in descending order is selected.
:::

## Configuring a mount mode

To configure a mount mode, see [Mount-modes-configuration.md].

### Sync modes and their downsides
File synchronization uses a novel algorithm that combines the performance and low-latency filesystem watching.
It uses to synchronize code between host machine and a remote container in effective real-time, allowing you to edit code with your editor of choice and have it pushed to the remote container almost instantly.

Sync modes downsides:
* Logs monitoring
* In general not stable solutions

To be updated by Mike.

### See also

* [Manage data in Docker](https://docs.docker.com/storage/)

* [Mutagen documentation](https://mutagen.io/documentation/introduction)

* [Docker-sync documentation](https://docker-sync.readthedocs.io/)
