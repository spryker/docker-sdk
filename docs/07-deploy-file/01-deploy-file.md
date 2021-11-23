# Deploy file

Deploy file is a [Docker Compose](https://docs.docker.com/compose/) YAML file used by the Docker SDK to build infrastructure for applications. The deploy file's structure is based on [YAML version 1.2 syntax](https://yaml.org/spec/1.2/spec.html).

## Deploy file inheritance

You can use multiple deploy files to define an application's infrastructure. The [`imports:`](02-deploy.file.reference.v1.md#imports) deploy file parameter is used to add additional deploy files to a build.

```yaml
import:
  custom_deploy_file.yml
```

When an application with multiple deploy files is being built, a deploy file builder parses and merges the deploy files into a single one at `/{DOCKER_SDK_DIRECTORY}/deployment/default/project.yml`.

The deploy file builder parses deploy files from the following layers:
* `Project layer`: located on a project layer at`./config/deploy-templates`.
* `Base layer`: located on the Docker SDK layer at`./{DOCKER_SDK_DIRECTORY}/generator/deploy-file-generator/templates`.

## Parameter inheritance

When merging deploy files, the deploy file builder merges duplicate parameters. Deploy files are merged in the following order:

1. `main deploy file`: deploy file on the project layer: `deploy.*.yml`.
2. `project layer`: all the deploy files in `./config/deploy-templates`, except the main one.
3. `base layer` - all the deploy files in `./**{docker-sdk-directory}**/generator/deploy-file-generator/templates`.

During a merge, each new value of a parameter overwrites the value of the parameter from the previous deploy file. For example, in `./**{docker-sdk-directory}**/generator/deploy-file-generator/templates/services.deploy.template.yml`, memory limit is defined as follows:

```yaml
image:
    ...
    php:
        ini:
            memory_limit: 512M
```
And, in `deploy.yml`, the same parameter is defined as follows:

```yaml
image:
    ...
    php:
        ini:
            memory_limit: 2048M
```

As a result, because `deploy.yml` is merged after `services.deploy.template.yml`, the memory limit value in `project.yml` is `2048M`.


## Dynamic parameters

A dynamic parameter is a YAML parameter that defines the value of a placeholder for an included deploy file. The deploy file builder replaces the placeholders with the dynamic parameter's value when merging deploy files.

For example, a deploy file includes another deploy file:

**deploy.yml**
```yaml
version: 1.0

imports:
    deploy.base.template.yml:
      parameters:
        env_name: 'dev'
```

The included deploy file includes more deploy files:

**deploy.base.template.yml**
```yaml
...

imports:
    environment/%env_name%/image.deploy.template.yml:
    environment/%env_name%/composer.deploy.template.yml:
    environment/%env_name%/assets.deploy.template.yml:
    environment/%env_name%/regions.deploy.template.yml:
    environment/%env_name%/groups.deploy.template.yml:
    environment/%env_name%/services.deploy.template.yml:
    environment/%env_name%/docker.deploy.template.yml:
```

When merging `deploy.base.template.yml` with `deploy.yml`, `%env_name%` is replaced with `dev`:

**deploy.base.template.yml**
```yaml
...

imports:
    environment/dev/image.deploy.template.yml:
    environment/dev/composer.deploy.template.yml:
    environment/dev/assets.deploy.template.yml:
    environment/dev/regions.deploy.template.yml:
    environment/dev/groups.deploy.template.yml:
    environment/dev/services.deploy.template.yml:
    environment/dev/docker.deploy.template.yml:
```
