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
