This document contains examples of using deploy file inheritance to avoid defining duplicate parameters in deploy files. Instead of creating a full deploy file with just one or two different parameter for an environment, you can create a deploy file with just the parameters unique to the environment.

For case, we provide examples

## Defining different domain names

Two environments have have the same infrastructure, except domain names.

### Defining different domain names via two full deploy files

Defined in two full deploy files, the configuration for two different domain names looks as follows:

**deploy.prod.yml**
```yaml
...
groups:
    EU:
        region: DE
        applications:
            Yves:
                application: yves
                endpoints:
                    spryker.com:
                        store: DE
...
```
**deploy.dev.yml**
```yaml
...
groups:
    EU:
        region: DE
        applications:
            Yves:
                application: yves
                endpoints:
                    test.spryker.com:
                        store: DE
...
```

### Defining different domains via deploy file inheritance


To define a different domain name for an environment using deploy file inheritance, do the following:

1. Create `config/deploy-templates/{DEPLOY_FILE_NAME}`. For example, `config/deploy-templates/groups.yml`.

2. As a domain name, add a dynamic parameter name. For example, add the `domain` parameter name.

**config/deploy-templates/groups.yml**
```yaml
groups:
    EU:
        region: DE
        applications:
            Yves:
                application: yves
                endpoints:
                    de.%domain%:
                        store: DE
```
3. In `deploy.prod.yml` and `deploy.dev.yml`, include `config/deploy-templates/groups.yml` with the `domain` parameter defined for each environment.

**deploy.prod.yml**
```yaml
...
imports:
    groups.yml:
        parameters:
            domain: spryker.com
...
```
**deploy.dev.yml**
```yaml
...
imports:
    groups.yml:
        parameters:
            domain: dev.spryker.com
...
```
***

## Enabling New Relic

By default, all the deploy files include `deploy.base.template.yml` from the base layer with parameters for each environment.

**deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```

By default, NewRelic is disabled. To enable it, you need to extend a deploy file or import a deploy file with enabled NewRelic.

### Enabling New Relic via the main deploy file

The configuration of enabled New Relic looks as follows:

**deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

docker:
    newrelic:
        license: eu01xxaa7460e1ea3abdfbbbd34e85c10cd0NRAL

imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```

### Enabling New Relic via a dedicated deploy file

To enable New Relic with a dedicated deploy file, do the following:

1. Create new file **config/deploy-templates/newrelic.yml**
```yaml
docker:
    newrelic:
        license: eu01xxaa7460e1ea3abdfbbbd34e85c10cd0NRAL
```

2. In `deploy.dev.yml`, include
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

imports:
    newrelic.yml:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
***

## Adding a new application

You can add a new application by extending the main deploy file or by including a dedicated deploy file with the application's configuration.

### Adding a new application via the main deploy file

The configuration of a new application in the main deploy file looks as follows:

**deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

groups:
    EU:
        region: DE
        applications:
            Mportal:
                application: merchant-portal
                endpoints:
                    mp.de.dev.spryker.com:
                        entry-point: MerchantPortal
                        store: DE
                        primal: true
                        services:
                            session:
                                namespace: 7

imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```

### Adding a new application via a dedicated deploy file

To add an application via an included deploy file, do the following:

1. Create `config/deploy-templates/merchant-application.yml`:
```yaml
groups:
    EU:
        region: DE
        applications:
            Mportal:
                application: merchant-portal
                endpoints:
                    mp.de.dev.spryker.com:
                        entry-point: MerchantPortal
                        store: DE
                        primal: true
                        services:
                            session:
                                namespace: 7
```

2. In `deploy.dev.yml`, include `merchant-application.yml`:

```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

imports:
    merchant-application.yml:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
***

## Adding services
docker/sdk has the `dashboard` service only for the `dev` environment. To enable it in any other environment, you need to extend the deploy file of the environment or include the deploy file with the configuration.


### Extend basic deploy file
**deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

services:
    dashboard:
        engine: dashboard
        endpoints:
            spryker.local:

imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```

### Import file with new services

1. create new file **config/deploy-templates/services.yml**
```yaml
services:
    dashboard:
        engine: dashboard
        endpoints:
            spryker.local:
```

2. extend basic deploy file **deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

imports:
    services.yml:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
***

## Change namespace:
If you need to change `namespace`, you need to change `namespace` in your deploy file or import new file with changed `namespace`:
### Extend basic deploy file
**deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker-dev
tag: 'dev'

environment: docker.dev

imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```

### Import file with new namespace
1. create new file **config/deploy-templates/namespace.yml**
```yaml
namespace: spryker-dev
```
2. extend basic deploy file **deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

imports:
    namespace.yml:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
***

## Add/extend region:
If you need to add new region or extend existed region,
you need to add region data in your deploy file or import new file with region data:
### Extend basic deploy file
#### Add new region **deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

regions:
    UK:
        services:
            mail:
                sender:
                    name: 'Spryker No-Reply'
                    email: no-reply@spryker.local
            database:
                database: uk-docker
        stores:
            UK:
                services:
                    broker:
                        namespace: uk-docker
                    key_value_store:
                        namespace: 1
                    search:
                        namespace: uk_search


imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
#### Extend US region **deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

regions:
    US:
        stores:
            CA:
                services:
                    broker:
                        namespace: ca-docker
                    key_value_store:
                        namespace: 4
                    search:
                        namespace: ca_search


imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
### Import file with regions
1. create new file **config/deploy-templates/regions.yml**
#### Add new region
```yaml
regions:
    UK:
        services:
            mail:
                sender:
                    name: 'Spryker No-Reply'
                    email: no-reply@spryker.local
            database:
                database: uk-docker
        stores:
            UK:
                services:
                    broker:
                        namespace: uk-docker
                    key_value_store:
                        namespace: 1
                    search:
                        namespace: uk_search
```
#### Extend US region
```yaml
regions:
    US:
        stores:
            CA:
                services:
                    broker:
                        namespace: ca-docker
                    key_value_store:
                        namespace: 4
                    search:
                        namespace: ca_search
```
2. extend basic deploy file **deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

imports:
    regions.yml:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
***

## Deleting regions
If you need to remove one or more regions, instead of using the default `deploy.base.template.yml` template, you need to init a custom one with specific regions.
***

## Disabling services

To disable a service, you need to add service data to the main deploy file or include a dedicated deploy file with service data.

### Extending the main deploy file to disable a service

**deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

services:
    dashboard: null

imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
***
### Including a deploy file with a disabled service

To disable a service by including a dedicated deploy file, do the following:

1. Create a deploy file with the services disabled:

**config/deploy-templates/disabled-dashboard.yml**
```yaml
services:
    dashboard: null
```

2. In the main deploy file, include the deploy file you've created:

**deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

imports:
    disabled-dashboard.yml:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
***
