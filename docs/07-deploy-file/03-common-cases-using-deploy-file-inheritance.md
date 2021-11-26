# Common cases:
## Different domains:
We have two environments with the same deploy file structure. One thing is different - domain.
Usually, we have two separate files for each environment:

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
                    de.cloud.spryker.toys:
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
                    de.dev.cloud.spryker.toys:
                        store: DE
...
```
For avoiding duplicate you should:
1) move section into separate file into `config/deploy-templates` directory for example: `config/deploy-templates/groups.yml`.
2) update this file by adding a parameter. For example parameter name is `domain`.

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
3) update `deploy.prod.yml` and `deploy.dev.yml`. Add imports `config/deploy-templates/groups.yml` and provide `domain` parameter for each environment.

**deploy.prod.yml**
```yaml
...
imports:
    groups.yml:
        parameters:
            domain: cloud.spryker.toys
...
```
**deploy.dev.yml**
```yaml
...
imports:
    groups.yml:
        parameters:
            domain: dev.cloud.spryker.toys
...
```
***

## Enabled NewRelic:
By default, all our deploy files have import `deploy.base.template.yml` from docker/sdk layer with parameters for each environment.
For example:

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
For each environment, NewRelic is disabled. For enabling, we to extend basic deploy file or import new file with NewRelic configuration.
### Extend basic deploy file
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
### Import file with NewRelicConfig
1) create new file **config/deploy-templates/newrelic.yml**
```yaml
docker:
    newrelic:
        license: eu01xxaa7460e1ea3abdfbbbd34e85c10cd0NRAL
```
2) extend basic deploy file **deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

docker:
    newrelic:
        license: eu01xxaa7460e1ea3abdfbbbd34e85c10cd0NRAL

imports:
    newrelic.yml:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
***

## Add new application:
If you need to add a new application for the default application list, you need to add a new application in your deploy file or import a new file with this configuration:
### Extend basic deploy file
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
                    mp.de.dev.cloud.spryker.toys:
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
### Import file with new application
1) create new file **config/deploy-templates/merchant-application.yml**
```yaml
groups:
    EU:
        region: DE
        applications:
            Mportal:
                application: merchant-portal
                endpoints:
                    mp.de.dev.cloud.spryker.toys:
                        entry-point: MerchantPortal
                        store: DE
                        primal: true
                        services:
                            session:
                                namespace: 7
```
2) extend basic deploy file **deploy.dev.yml**
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

## Add new services:
For example, docker/sdk has `dashboard` service for `dev` environment only. For enabled this service in your environment, you need to add a new service in your deploy file or import a new file with this configuration:
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
1) create new file **config/deploy-templates/services.yml**
```yaml
services:
    dashboard:
        engine: dashboard
        endpoints:
            spryker.local:
```
2) extend basic deploy file **deploy.dev.yml**
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
1) create new file **config/deploy-templates/namespace.yml**
```yaml
namespace: spryker-dev
```
2) extend basic deploy file **deploy.dev.yml**
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
1) create new file **config/deploy-templates/regions.yml**
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
2) extend basic deploy file **deploy.dev.yml**
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

## Delete region:
If you need to remove one or several regions, you can't use the default template(`deploy.base.template.yml`).
You need to init yours with specific regions.
***

## Disabling services:
If you need to disable one of services, you need to add service data in your deploy file or import new file with service data:
### Extend basic deploy file **deploy.dev.yml**
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
### Import file with regions
1) create new file **config/deploy-templates/service.yml**
```yaml
services:
    dashboard: null
```
***
2) extend basic deploy file **deploy.dev.yml**
```yaml
version: '0.1'

namespace: spryker
tag: 'dev'

environment: docker.dev

imports:
    service.yml:
    deploy.base.template.yml:
        parameters:
            env_name: 'dev'
```
***
