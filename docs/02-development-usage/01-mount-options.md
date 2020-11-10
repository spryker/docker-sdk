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

### How to select mount option for the development purpose?

During the development it's required to select mount option to synchronize code between host machine and a remote container in effective real-time way.
In the table below you can find suitable mount option depends on your operation system.

| Mount option | MacOS       | Linux      | Windows (WSL1) | Windows (WSL2)  |
|--------------|-------------|------------|----------------|-----------------|
| native       | &#x2611; ^  | &#x2611; * | &#x2611; ^     | &#x2611; *      |
| mutagen      | &#x2611; *  | -          | -              | -               |
| docker-sync  | &#x2611;    | -          | &#x2611; *     | -               |

* (^) - the performance is very slow.
* (*) - recommended mount option for the platform.
* (-) - not supported mount option.

### What mount modes does docker/sdk support?

docker/sdk supports the following modes for mounting source files into the application containers:

* baked.\
Performs the source files copying into image, so they *cannot* be changed from host machine.
The file or directory is referenced by its absolute path on the host machine.

**NOTE:**
The default mount option for the demo mode.

* native.\
Performs the source files mounting from host machine into containers directly.
Works perfectly with Linux.

**NOTE:**
It works perfectly as a solution for Linux and Windows (WS2) platforms.

* docker-sync.\
Performs the source files synchronization from host machine into containers during runtime.

**NOTE:**
It works stable as a solution with MacOS and Windows(WS1) platforms.

* mutagen.\
Performs the source files synchronization between your host machine, and a remote container in effective real-time way that combines the performance of the rsync algorithm with bidirectionality and low-latency filesystem watching.

**NOTE:**
It works stable as a solution for MacOS platform.

### How do I change a mount mode?

As `docker: mount:` is a platform-specific configuration setting.
During the configuration process its possible to define multiple mount modes depends on the required platform. Possible platforms are windows, macos and linux.
Check the configuration example below:

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

**Note:**
The first mount mode matching the host platform is chosen.

## How to configure required mount mode:
[link to mount-modes-configuration.md] file.

### How do sync modes work and what are their downsides?
The file synchronization uses a novel algorithm that combines the performance and low-latency filesystem watching.
It uses to synchronize code between host machine and a remote container in effective real-time, allowing you to edit code with your editor of choice and have it pushed to the remote container almost instantly.

Sync modes downsides:
* Logs monitoring.
* In general not stable solutions.

### What related Docker Desktop and Github documentation can I check?

* Docker:
    * https://docs.docker.com/storage/

* Mutagen:
    * https://mutagen.io/

* Docker-sync:
    * https://docker-sync.readthedocs.io/en/latest/
