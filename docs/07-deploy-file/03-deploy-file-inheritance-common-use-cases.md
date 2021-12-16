This document contains examples of using deploy file inheritance. The examples show how to do the following:
* Avoid defining duplicate parameters in deploy files.
* Re-use configuration from a deploy file in multiple deploy files.
* Use dynamic parameters when the a configuration is re-used in multiple environments.

For comparison, we provide examples of achieving the same result with and without deploy file inheritance.

## Defining domain names

The following examples show how you can define different domain names for two environments.

### Defining domain names via main deploy files

Defined in main deploy files, the configuration of different domain names looks as follows:

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
                    dev.spryker.com:
                        store: DE
...
```

### Defining domain names via a dedicated deploy file


To define domain names by including a dedicated deploy file with a dynamic parameter, do the following:

1. Create `config/deploy-templates/{DEPLOY_FILE_NAME}`. For example, `config/deploy-templates/groups.yml`.

2. Define the domain name as a dynamic parameter. For example, define it as a `domain` parameter name.

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

3. In `deploy.prod.yml` and `deploy.dev.yml`, include `config/deploy-templates/groups.yml` with the `domain` dynamic parameter defined for each environment.

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

By default, NewRelic is disabled. The following examples show how you can enable New Relic with different license keys in two environments.

### Enabling New Relic via main deploy files

The configuration of enabled New Relic looks as follows in main deploy files:

**deploy.prod.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.prod

docker:
    newrelic:
        license: sker759fsdu01xkdotunc85334e85c10cd0jh67f

imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'prod'
```


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

1. Create `config/deploy-templates/{DEPLOY_FILE_NAME}`. For example, `config/deploy-templates/enabled-newrelic.yml`.

2. Define New Relic as enabled with the license key defined dynamically:
```yaml
docker:
    newrelic:
        license: %license_key%
```

2. In `deploy.prod.yml` and `deploy.dev.yml`, include `config/deploy-templates/enabled-newrelic.yml` with the `license_key` dynamic parameter  defined for each environment.

**deploy.prod.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'produ'

environment: docker.prod

imports:
    enabled-newrelic.yml:
      parameters:
          license_key: 'sker759fsdu01xkdotunc85334e85c10cd0jh67f'
    deploy.base.template.yml:
        parameters:
            env_name: 'prod'
```

**deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

imports:
    enabled-newrelic.yml:
      parameters:
          license_key: 'eu01xxaa7460e1ea3abdfbbbd34e85c10cd0NRAL'
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
***


## Adding an application

The following examples shows how to add two applications with different endpoints.

### Adding an application via main deploy files

The configuration of a new application in main deploy files looks as follows:

**deploy.prod.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'prod'

environment: docker.prod

groups:
    EU:
        region: DE
        applications:
            Mportal:
                application: merchant-portal
                endpoints:
                    mp.de.spryker.com:
                        entry-point: `MerchantPortal`
                        store: DE
                        primal: true
                        services:
                            session:
                                namespace: 7

imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'prod'
```



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

### Adding an application via a dedicated deploy file

To add an application via an included deploy file, do the following:


1. Create `config/deploy-templates/{DEPLOY_FILE_NAME}`. For example, `config/deploy-templates/merchant-application.yml`.

2. Define the application with the endpoint defined dynamically:
```yaml
groups:
    EU:
        region: DE
        applications:
            Mportal:
                application: merchant-portal
                endpoints:
                    '%hostname%':
                        entry-point: MerchantPortal
                        store: DE
                        primal: true
                        services:
                            session:
                                namespace: 7
```

2. In `deploy.prod.yml` and `deploy.dev.yml`, include `merchant-application.yml` with the `hostname` dynamic parameter defined:

**deploy.prod.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'prod'

environment: docker.prod

imports:
    merchant-application.yml:
      parameters:
          hostname: 'mp.de.spryker.com'      
    deploy.base.template.yml:
        parameters:
            env_name: 'prod'
```


**deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

imports:
    merchant-application.yml:
      parameters:
          hostname: 'mp.de.dev.spryker.com'      
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
***

## Enabling services

The Docker SDK has the `dashboard` service enabled by default only for the `dev` environment. The following examples show how you can enable it for demo and production environments with different endpoints.


### Enabling services via main deploy files

The configuration of enabled dashboard looks as follows in main deploy files:

**deploy.prod.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'prod'

environment: docker.prod

services:
    dashboard:
        engine: dashboard
        endpoints:
            dashboard.spryker.com:

imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'prod'
```

**deploy.demo.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'demo'

environment: docker.demo

services:
    dashboard:
        engine: dashboard
        endpoints:
            dashboard.demo-spryker.local:

imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'demo'
```




### Enable services via a dedicated deploy file

To enable dashboard via a dedicated deploy file with endpoing defined dynamically, do the following:

1. Create `config/deploy-templates/{DEPLOY_FILE_NAME}`. For example, `config/deploy-templates/services.yml`.

2. Add the configuration of an enabled dashboard with the endpoint defined dynamically.
```yaml
services:
    dashboard:
        engine: dashboard
        endpoints:
            '%dashboard_hostname%':
```

2. In `deploy.prod.yml` and `deploy.dev.yml`, include `services.yml` with the `dashboard_hostname` dynamic parameter defined:

**deploy.prod.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'prod'

environment: docker.prod

imports:
    services.yml:
      parameters:
          dashboard_hostname: 'dashboard.spryker.com'
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```

**deploy.demo.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'demo'

environment: docker.demo

imports:
    services.yml:
      parameters:
          dashboard_hostname: 'dashboard.demo-spryker.local'
    deploy.base.template.yml:
        parameters:
            env_name: 'demo'
```
***

## Changing namespaces

The following examples show how to set different namespaces for two environments.

### Changing namespaces via main deploy files

The namespaces defined via main deploy files look as follows:

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
**deploy.prod.yml**
```yaml
version: '0.1'

namespace: spryker-prod
tag: 'prod'

environment: docker.prod

imports:
    deploy.base.template.yml:
        parameters:
            env_name: 'prod'
```

### Changing namespaces via a dedicated deploy file

To create a deploy file with a dynamic configuration and re-use it in multiple environments, do the following:

1. Create `config/deploy-templates/{DEPLOY_FILE_NAME}`. For example, `config/deploy-templates/namespace.yml`.

2. In `namespace.yml`, define the namespace name with the environment name defined dynamically:
```yaml
namespace: spryker-%env_name%
```

2. In `deploy.prod.yml` and `deploy.prod.yml`, include `namespace.yml` with the `env_name` dynamic parameter defined:

**deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

imports:
    namespace.yml:
      parameters:
          env_name: 'dev'      
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```

**deploy.prod.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'prod'

environment: docker.prod

imports:
    namespace.yml:
      parameters:
          env_name: 'prod'      
    deploy.base.template.yml:
        parameters:
            env_name: 'prod'
```
***


## Adding regions
To add a new region, you can extend the deploy files of the desired environments or create a dedicated deploy file and re-use it in the deploy files of the desired environments.

### Adding regions via the main deploy files

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

### Adding regions via a dedicated deploy file

1. Create `config/deploy-templates/{DEPLOY_FILE_NAME}`. For example, `config/deploy-templates/regions.yml`.

2. In `regions.yml`, define the configuration you want to extend the existing configuration with:

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

3. Include `regions.yml` into the build of the desired environments by extending their respective deploy files as follows:

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

## Extending regions

Since the region's configuration is already defined in `deploy.base.template.yml`, you don't need to duplicate it in the deploy files. You just need to define the new configuration.

### Extending regions via the main deploy files

In this example, we extend the US region which is defined in `deploy.base.template.yml`.

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

### Extending regions via a dedicated deploy file

1. Create `config/deploy-templates/{DEPLOY_FILE_NAME}`. For example, `config/deploy-templates/regions.yml`.

2. In `regions.yml`, define the configuration you want to extend the existing configuration with:
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

3. Include `regions.yml` into the build of the desired environments by extending their respective deploy files as follows:

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

## Removing regions
To remove one or more regions, instead of using the default `deploy.base.template.yml` template, you need to init a custom one with specific regions.
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


1. Create `config/deploy-templates/{DEPLOY_FILE_NAME}`. For example, `config/deploy-templates/disabled-dashboard.yml`.

```yaml
services:
    dashboard: null
```

2. In `deploy.prod.yml` and `deploy.prod.yml`, include `disabled-dashboard.yml`:

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
