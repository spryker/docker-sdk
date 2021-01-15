This document is a draft. See [Docker SDK](https://documentation.spryker.com/docs/docker-sdk) for official documentation.

## Description
Read the description below and, in the *Structure* section, fill out the document by answering the questions directly.

> Audience:
>
> - Devops who use docker/sdk for production or staging environments.
>
> Outcome:
> - You know how to configure deployment pipeline using docker/sdk.

## Outline

1. The example of deployment pipeline. Figure.
2. How to configure deployment pipeline in deploy.yml.
3. Example of pipelines
```
image:
    tag: spryker/php:7.3
    environment:
      SPRYKER_HOOK_BEFORE_DEPLOY: "vendor/bin/install -r pre-deploy -vvv"
      SPRYKER_HOOK_AFTER_DEPLOY: "true"
      SPRYKER_HOOK_INSTALL: "vendor/bin/install -r production --no-ansi -vvv"
      SPRYKER_HOOK_DESTRUCTIVE_INSTALL: "vendor/bin/install -r destructive --no-ansi -vvv"
```
4. How to run pipeline steps during a deployment.
 - Use application image where particular env variables are set.
 - Run "${SPRYKER_HOOK_BEFORE_DEPLOY}" or other env depends on a step.
 - Examples for AWS pipelines.


## Structure

:::(Info)(Structure)
The structure below is just a reference. We encourage you to add subsections, change or swap the provided sections if needed.
:::

### What is this document about?


### What would be an example of a deployment pipeline?


### How do I configure a deployment pipeline in deploy file?
#### What would be examples of deployment pipelines in deploy file?


### How do I run pipeline steps during deployment?
