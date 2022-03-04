# Quick start guide

This document describes how you can quickly set up a local environment with the Docker SDK.

## Running the Docker SDK in a local environment

To run the Docker SDK in a local environment, follow the instructions below.

### Installing Docker

For Docker installation instructions, see one of the following:
* [Installing Docker prerequisites on MacOS](06-installation/01-installation-prerequisites/01-installing-docker-prerequisites-on-macos.md)
* [Installing Docker prerequisites on Linux](06-installation/01-installation-prerequisites/01-installing-docker-prerequisites-on-linux.md)
* [Installing Docker prerequisites on Windows](06-installation/01-installation-prerequisites/01-installing-docker-prerequisites-on-windows.md)

### Setting up a project with the Docker SDK

To set up a local project with the Docker SDK:

1. Create the project directory and clone the source:
```bash
mkdir {project-name} && cd {project-name}
git clone https://github.com/{project-url} ./
```

2. Clone the latest version of the Docker SDK:

```bash
git clone git@github.com:spryker/docker-sdk.git docker
```


## Setting up a developer environemnt

To set up a developer environment:

1. Bootstrap docker setup, build and start the instance:

```bash
docker/sdk boot deploy.dev.yml
docker/sdk up
```

2. Switch to your project branch, re-build the application with assets and demo data from the new branch:

```bash
git checkout {your_branch}
docker/sdk boot deploy.dev.yml
docker/sdk up --build --assets --data
```

Depending on your requirements, you can select any combination of the following `up` command attributes. To fetch all the changes from the branch you switch to, we recommend running the command with all of them:
- `--build` - update composer, generate transfer objects, etc.
- `--assets` - build assets
- `--data` - fetch new demo data


## Setting up a production-like environment

To set up a production-like environment:

1. Bootstrap docker setup, build and start the instance:

```bash
docker/sdk boot deploy.*.yml
docker/sdk up
```

2. Switch to your project branch, re-build the application with assets and demo data from the new branch:

```bash
git checkout {your_branch_name}
docker/sdk boot
docker/sdk up --build --assets --data
```

Depending on your requirements, you can select any combination of the following `up` command attributes. To fetch all the changes from the branch you switch to, we recommend running the command with all of them:
- `--build` - update composer, generate transfer objects, etc.
- `--assets` - build assets
- `--data` - get new demo data


## Troubleshooting

For solutions to common issues, see [Troubleshooting](09-troubleshooting.md).


## What documents should I use to start developing and configuring my project?
<!--- [02-development-usage] --->
[Deploy file reference — 1.0](07-deploy-file/02-deploy-file-reference.v1.md)
[Configuration reference](10-configuration-reference.md)
[Configuring servces](06-configuring-services.md)
