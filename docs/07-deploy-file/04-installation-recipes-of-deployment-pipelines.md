# Installation recipes of deployment pipelines

Installation recipes contain the commands that are run during the [install stage of deployment pipelines](https://docs.spryker.com/docs/cloud/dev/spryker-cloud-commerce-os/configure-deployment-pipelines/deployment-pipelines.html#install-stage). The recipes are located in `config/install/`.  For example, this is how they look in the [B2C Demo Shop](https://github.com/spryker-shop/b2c-demo-shop/tree/master/config/install):

```
config
├── install
│   ├── ci.yml
│   ├── development.yml
│   ├── docker.ci.acceptance.yml
│   ├── docker.ci.api.yml
│   ├── docker.ci.functional.yml
│   ├── docker.yml
│   ├── EU
│   │   ├── destructive.yml
│   │   ├── pre-deploy.yml
│   │   └── production.yml
│   ├── sniffs.yml
│   ├── testing.yml
│   └── US
│       ├── destructive.yml
│       ├── pre-deploy.yml
│       └── production.yml
```

The default recipe for any project is [config/install/docker.yml](https://github.com/spryker-shop/b2c-demo-shop/blob/master/config/install/docker.yml). You can define a different recipe in a [deploy](https://docs.spryker.com/docs/scos/dev/the-docker-sdk/202204.0/deploy-file/deploy-file.html) file. The default value is as follows:

```shell
pipeline: 'docker'
```

There can be multiple recipes for the same project. For example, there can be recipes for environments, like local, stage, or prod, and for different purposes, like for CI, development, or testing.

## Recipe file structure

A default recipe file can be split into four logical blocks:

1) Build sections:

    - `build`: build a pre-generated code base like transfer, cache, and schema.
    - `build-production`: build a pre-generated code base specific to the production environment.
    - `build-development`: build a pre-generated code base specific to the development environment.

2) Assets sections:

    - `build-static`: install frontend dependencies.
    - `build-static-production`: install the dependencies specific to the production environment.
    - `build-static-development`: install the dependencies specific to the development environment.

3) Data sections:

    - `init-storage`: initialize the common storage.
    - `init-storages-per-region`: initialize, migrate, and validate storages per region.
    - `init-storages-per-store`: initialize storages per store.
    - `clean-storage`: clean storage.
    - `demodata`: import and prepare demo data.

4) Job sections:

    - `scheduler-setup`:  set up the scheduler.
    - `scheduler-suspend`: suspend the scheduler.
    - `scheduler-clean`: clean the scheduler.

These sections are part of the [Docker SDK](https://docs.spryker.com/docs/scos/dev/the-docker-sdk/202204.0/the-docker-sdk.html) and cannot be renamed.

## Customization of recipes

You can add custom commands to default sections as follows:

```shell
build-development:
    custom-command:
        command: 'vendor/bin/console custom:command'
    ...
```

To hide the output of a command, use the `excluded` parameter:

```shell
sections:
    hidden:
        excluded: true
        hidden-command:
            command: 'vendor/bin/console specific:command'
```

You can add custom sections to any recipe:

```shell
jenkins-up:
    jenkins-generate:
        command: 'vendor/bin/console scheduler:setup'
        stores: true
```

For examples, see [b2c-demo-shop](https://github.com/spryker-shop/b2c-demo-shop/blob/master/config/install/development.yml).

## Staging and Production environment recipes

For [Staging and Production](https://docs.spryker.com/docs/cloud/dev/spryker-cloud-commerce-os/environments-overview.html) environments, there are [dedicated installation recipes](https://github.com/spryker-shop/b2c-demo-shop/tree/master/config/install/EU) with custom sections:

- destructive.yml
- pre-deploy.yml
- production.yml

You can use them as a hook definition when [customizing pipelines](https://docs.spryker.com/docs/cloud/dev/spryker-cloud-commerce-os/configure-deployment-pipelines/customizing-deployment-pipelines.html#adding-a-single-command-to-a-deployment-pipeline):

```shell
image:
    tag: spryker/php:8.1
    environment:
        SPRYKER_HOOK_BEFORE_DEPLOY: 'vendor/bin/install -r EU/pre-deploy -vvv'
        SPRYKER_HOOK_INSTALL: 'vendor/bin/install -r EU/production --no-ansi -vvv'
        SPRYKER_HOOK_DESTRUCTIVE_INSTALL: 'vendor/bin/install -r EU/destructive --no-ansi -vvv'
```

Production recipe is used in a `Normal deploy` pipeline that includes all the stages of a complete CI/CD flow. This pipeline does not perform any dangerous data manipulations like database cleanup or scheduler reset. Use it for production deployments.

Destructive recipe is used in a `Destructive deploy` pipeline that includes all the stages of a complete CI/CD flow. This pipeline resets all the data in applications. Use it for initial or non-production deployments.

## Run recipes manually

To run a recipe manually, run the command:

```shell
vendor/bin/install -r {RECIPE_NAME}
```

For example, run the [config/install/docker.yml](https://github.com/spryker-shop/b2c-demo-shop/blob/master/config/install/docker.yml) recipe:

```shell
vendor/bin/install -r docker
```

To run a particular section of a recipe, run the command:

```shell
vendor/bin/install -r {RECIPE_NAME} -s {SECTION_NAME}
```

For example, run the build section of [config/install/docker.yml](https://github.com/spryker-shop/b2c-demo-shop/blob/master/config/install/docker.yml):
```shell
vendor/bin/install -r docker -s build
```

To run several sections of a recipe, list them as follows:
```shell
vendor/bin/install -r docker -s build -s build-static -s build-development
```
