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

### How do I run docker/sdk in my local environment?

#### Docker installation

For more details please check [03.installation.md]

### Installation

Run the command:

Clone docker/sdk from the remote repository.

```bash
mkdir {project-name} && cd {project-name}
git clone https://github.com/{project-name} ./
git clone git@github.com:spryker/docker-sdk.git docker
```


### Developer environment set up

#### Run the command right after cloning the repository:

```bash
docker/sdk boot deploy.dev.yml
docker/sdk up
```

#### Git checkout:

```bash
git checkout {your_branch}
docker/sdk boot -s deploy.dev.yml

docker/sdk up --build --assets --data
```
> Optional `up` command arguments:
>
> - `--build` - update composer, generate transfer objects, etc.
> - `--assets` - build assets
> - `--data` - get new demo data


### Production-like environment set up

#### Run the following command right after cloning the repository:

```bash
docker/sdk boot -s
docker/sdk up
```

#### Git checkout with assets and importing data:

```bash
git checkout {your_branch_name}
docker/sdk boot -s

docker/sdk up --build --assets --data
```

> Optional `up` command arguments:
>
> - `--build` - update composer, generate transfer objects, etc.
> - `--assets` - build assets
> - `--data` - get new demo data

#### Light git checkout:

```bash
git checkout {your_branch_name}
docker/sdk boot -s

docker/sdk up
```

#### Reload all the data:

```bash
docker/sdk clean-data && docker/sdk up && docker/sdk console q:w:s -v -s
```

### Troubleshooting

Link to the [09-troubleshooting.md]


### What documents should I use to start developing and configuring my project?
[02-development-usage]
[99-deploy.file.reference.v1.md]
[10-how-to-configure.md]
[06-services.md]
