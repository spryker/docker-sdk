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

### What mount modes does docker/sdk support?

docker/sdk supports the following modes for mounting source files into the application containers:

**when**
```yaml
docker:
    ...

    mount:
        baked:
```

**then**
Source files are copied into image, so they cannot be changed from host machine. The file or directory is referenced by its absolute path on the host machine.

**when**
```yaml
docker:
    ...

    mount:
        native:
```

**then**
Source files are mounted from host machine into containers directly. Works perfectly with Linux.


**when**
```yaml
docker:
    ...

    mount:
        docker-sync:
```

**then**
Source files are synced from host machine into containers during runtime. Works as a workaround solution with MacOS and Windows.

### How do I change a mount mode?

As `docker: mount:` is a platform-specific setting, its possible to define multiple mount modes.
The mount mode for a particular platform can be specified by using platforms: list.
Possible platforms are windows, macos and linux.
Check the example below:

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

### How do sync modes work and what are their downsides?
The file synchronization uses a novel algorithm that combines the performance of the rsync algorithm with bidirectionality and low-latency filesystem watching.
It uses to synchronize code between host machine and a remote container in effective real-time, allowing you to edit code with your editor of choice and have it pushed to the remote environment almost instantly.

### What related Docker Desktop and Github documentation can I check?

