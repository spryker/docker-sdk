This document is a draft. See [Docker SDK](https://documentation.spryker.com/docs/docker-sdk) for official documentation.

## Description
Read the description below and, in the *Structure* section, fill out the document by answering the questions directly.


> Audience:
>
> - Everybody who is not familiar with docker/sdk.
>
> Outcome:
> - You have a list of steps on how to quickly run Spryker in local environment.

## Outline

1. Getting started steps.
2. Links to other documents for whom wants more details.


## Structure

:::(Info)(Structure)
The structure below is just a reference. We encourage you to add subsections, change or swap the provided sections if needed.
:::

### Running docker/sdk in a local environment

#### Docker installation

For Docker installation instructions, see [03.installation.md].

#### Project setup with docker/sdk

To set up your project with docker/sdk locally:

1. Create the project directory and clone the source:
```bash
mkdir {project-name} && cd {project-name}
git clone https://github.com/{project-url} ./
```

2. Clone the latest version of docker/sdk:

```bash

git clone git@github.com:spryker/docker-sdk.git docker
```


### Developer environment setup

To set up developer environment:

1. Bootstrap docker setup, build and start the instance:

```bash
docker/sdk boot deploy.dev.yml
docker/sdk up
```

2. Switch your project branch, re-build the application with assets and demo data from the new branch:

```bash
git checkout {your_branch}
docker/sdk boot deploy.dev.yml
docker/sdk up --build --assets --data
```

Depending on your requirements, you can select any combination of the following `up` command attributes. To fetch all the changes from the branch you switch to, we recommend running the command with all of them:
- `--build` - update composer, generate transfer objects, etc.
- `--assets` - build assets
- `--data` - get new demo data


### Production-like environment setup

To set up a production-like environment:

1. Bootstrap docker setup, build and start the instance:

```bash
docker/sdk boot deploy.*.yml
docker/sdk up
```

2. Switch your project branch, re-build the application with assets and demo data from the new branch:

```bash
git checkout {your_branch_name}
docker/sdk boot
docker/sdk up --build --assets --data
```

Depending on your requirements, you can select any combination of the following `up` command attributes. To fetch all the changes from the branch you switch to, we recommend running the command with all of them:
- `--build` - update composer, generate transfer objects, etc.
- `--assets` - build assets
- `--data` - get new demo data


### Troubleshooting

For solutions to common issues, see [Troubleshooting].


### What documents should I use to start developing and configuring my project?
[02-development-usage]
[99-deploy.file.reference.v1.md]
[10-how-to-configure.md]
[06-services.md]
