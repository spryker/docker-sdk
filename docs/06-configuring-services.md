# Configuring services

This document describes configuration options of the services shipped with Spryker in Docker by default.  Find the list of the services below:

*     [Database](#database)
*     [ElasticSearch](#elasticsearch)
*     [OpenSearch](#opensearch)
*     [Kibana UI](#kibana-ui)
*     [RabbitMQ](#rabbitmq)
*     [Swagger UI](#swagger-ui)
*     [Redis](#redis)
*     [Redis GUI](#redis-gui)
*     [MailHog](#mailhog)
*     [Mailpit](#mailpit)
*     [Blackfire](#blackfire)
*     [New Relic](#new-relic)
*     [WebDriver](#webdriver)
*     [Dashboard](#dashboard)
*     [Tideways](#tideways)
*     [Local OpenTelemetry Stack](#grafana)
*     [Custom Services](#custom-services)


## Prerequisites

Install or update the Docker SDK to the latest version:
```bash
git clone https://github.com/spryker/docker-sdk.git ./docker
```


## Optional services

All services are optional, but each application requires certain services to work properly. Dependencies per service:

| Service name    | Application Dependencies                                                                     |
|-----------------|----------------------------------------------------------------------------------------------|
| database        | backoffice, backend-gateway, zed, merchant-portal, glue-backend                              |
| broker          | backoffice, backend-gateway, zed, merchant-portal, glue-backend                              |
| key_value_store | backoffice, backend-gateway, zed, yves, merchant-portal, glue, glue-storefront, glue-backend |
| session         | backoffice, zed, yves, merchant-portal, glue-backend                                         |
| search          | backoffice, backend-gateway, zed, yves, merchant-portal, glue, glue-storefront, glue-backend |



## Database
[MariaDB](https://mariadb.org/) is provided as a service by default, but you can switch to MySQL or PostgreSQL as described below.

### MariaDB
[MariaDB](https://mariadb.org/) is a community-developed, commercially supported fork of the [MySQL](https://www.mysql.com/) relational database management system.

See [MariaDB knowledge base](https://mariadb.com/kb/en/) for more details.

:::(Warning) (Default service)
MariaDB is provided as a service by default. You may only need to use this configuration if you are running an older version of the Docker SDK or if you've previously switched to another database engine.
:::

#### Configuration
Follow the steps below to switch the database service to MariaDB:

1. Adjust `deploy.*.yml` in the `services:` section:

```yaml
...
services:
    database:
        engine: mysql
        version: mariadb-10.11
        ...
        endpoints:
            localhost:3306:
...
```

2. Bootstrap the docker setup, regenerate demo data, and rebuild the application:
```bash
docker/sdk boot deploy.*.yml
docker/sdk clean-data
docker/sdk up --build --data
```


### MySQL
[MySQL](https://www.mysql.com) is an open source relational database management system based on Structured Query Language (SQL). MySQL enables data to be stored and accessed across multiple storage engines, including InnoDB, CSV and NDB. MySQL is also capable of replicating data and partitioning tables for better performance and durability.

See [MySQL documentation](https://dev.mysql.com/doc/) for more details.

#### Configuration
Follow the steps below to switch database engine to MySQL:
1. Adjust `deploy.*.yaml` in the `services:` section:
```yaml
...
services:
    database:
        engine: mysql
        ...
        endpoints:
            localhost:3306:
...
```
2. Bootstrap the docker setup, regenerate demo data, and rebuild the application:
```bash
docker/sdk boot deploy.*.yml
docker/sdk clean-data
docker/sdk up --build --data
```


### PostgreSQL
[PostgreSQL](https://www.postgresql.org/) PostgreSQL is a powerful, open source object-relational database system that uses and extends the SQL language combined with many features that safely store and scale the most complicated data workloads.

See [PostgreSQL documentation](https://www.postgresql.org/docs/) for more details.

#### Configuration
Follow the steps below to switch database engine to PostgreSQL:
1. Adjust `deploy.*.yml` in the `services:` section:
```yaml
...
services:
    database:
        engine: postgres
        ...
        endpoints:
            localhost:5432:
...
```
2. Bootstrap the docker setup, regenerate demo data, and rebuild the application:
```bash
docker/sdk boot deploy.*.yml
docker/sdk clean-data
docker/sdk up --build --data
```

## ElasticSearch

[Elasticsearch](https://www.elastic.co/elasticsearch/) is a search engine based on the Lucene library. It provides a distributed, multitenant-capable full-text search engine with an HTTP web interface and schema-free JSON documents.

See:
* [Configuring Elasticsearch](https://documentation.spryker.com/docs/search-configure-elasticsearch) to learn more about Elastcisearch configuration in Spryker.
* [Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html) for more information on Elasticsearch.

### Configuration

1. Adjust `deploy.*.yml` in the `services:` section to open the port used for accessing ElasticSearch:
```yaml
services:
    search:
        engine: elastic
        endpoints:
            localhost:9200
                protocol: tcp
```

2. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up

## OpenSearch

[OpenSearch](https://opensearch.org/docs/1.3/) is a search engine based on the Lucene library. It provides a distributed, multitenant-capable full-text search engine with an HTTP web interface and schema-free JSON documents.

### Configuration

1. Adjust `deploy.*.yml` in the `services:` section to open the port used for accessing OpenSearch:
```yaml
services:
    search:
        engine: opensearch
        endpoints:
            localhost:9200
              protocol: tcp


2. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

## Kibana UI

[Kibana](https://www.elastic.co/kibana) is an open source analytics and visualization platform designed to work with Elasticsearch. You use Kibana to search, view, and interact with data stored in Elasticsearch indices. You can easily perform advanced data analysis and visualize your data in a variety of charts, tables, and maps.

See [Kibana documentation](https://www.elastic.co/guide/en/kibana/current/index.html) to learn more.

In Docker SDK, Kibana UI is provided as a service by default.

### Configuration
Follow the steps to configure an endpoint for Kibana UI:
1. Adjust `deploy.*.yml` in the `services:` section:
```yaml
services:
    ...
    kibana:
        engine: kibana
        endpoints:
            {custom_endpoint}:
```
2. Adjust host file, if `{custom_endpoint}` aren't ending on `.localhost`:
```bash
echo "127.0.0.1 {custom_endpoint}" | sudo tee -a /etc/hosts
```

3. 2. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

## RabbitMQ

[RabbitMQ](https://www.rabbitmq.com/) is a messaging broker - an intermediary for messaging. It gives your applications a common platform to send and receive messages, and your messages a safe place to live until received.

### Configuration

1. Adjust `deploy.*.yml` in the `services:` section to open the port used for accessing RabbitMQ:
```yaml
services:
    broker:
    ...
        endpoints:
    ...
            localhost:5672:
                protocol: tcp
            api.queue.spryker.local:
```

2. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

### Migrating to RabbitMQ 4.1 in Production

When upgrading to RabbitMQ 4.1 in production environments, follow these steps to ensure a safe migration:

{% info_block infoBox %}
RabbitMQ 3.13 is the last version before 4.1. Make sure you are running version 3.13 before upgrading to 4.1.
{% endinfo_block %}

#### Migration Steps

1. **Ensure you are on RabbitMQ 3.13**: Verify that your current RabbitMQ version is 3.13, which is the last version before 4.1.

2. **Stop Jenkins**: Before proceeding with the migration, stop all Jenkins jobs and the Jenkins service to prevent any message processing during the upgrade:

3. **Apply changes**: Apply the necessary configuration changes to update the RabbitMQ service to the new version.

4. **Restart Jenkins**: Once the migration is complete and verified, restart the Jenkins service.

## Swagger UI

[Swagger UI](https://swagger.io/tools/swagger-ui/) allows anyone — be it your development team or your end consumers — to visualize and interact with the API’s resources without having any of the implementation logic in place. It’s automatically generated from your OpenAPI (formerly known as Swagger) Specification, with the visual documentation making it easy for back end implementation and client-side consumption.

See [Swagger UI documentation](https://swagger.io/docs/open-source-tools/swagger-ui/usage/installation/) for more details.

In Docker SDK, Swagger UI is provided as a service by default.

### Rest API Reference in Spryker

Spryker provides the basic functionality to generate [OpenApi schema specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md) for REST API endpoints. This document provides an overview of REST API endpoints. For each endpoint, you will find the URL, REST request parameters as well as the appropriate request and response data formats.

### Configuration
Follow the steps to configure an endpoint for Swagger UI:
1. Adjust `deploy.*.yml` in the `services:` section:
```yaml
services:
    ...
    swagger:
        engine: swagger-ui
        endpoints:
            {custom_endpoint}:
```

2. Adjust the `host` file, if `{custom_endpoint}` aren't ending on `.localhost`:
```bash
echo "127.0.0.1 {custom_endpoint}" | sudo tee -a /etc/hosts
```

3. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```
## Redis

[Redis](https://redis.io) is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker. It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs, geospatial indexes with radius queries and streams.

See [Redis documentation](https://redis.io/documentation) for more details.

### Configuration

1. Adjust `deploy.*.yml` in the `services:` section to open the port used for accessing Redis:
```yaml
services:
    key_value_store:
        engine: redis
        endpoints:
            localhost:16379:
                protocol: tcp
```

2. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

## Redis GUI
[Redis Commander](http://joeferner.github.io/redis-commander/) is a web management tool that provides a graphical user interface to access Redis databases and perform basic operations like view keys as a tree, view CRUD keys or import/export databases.

### Configuration
Follow the steps to configure an endpoint for Redis Commander:

1. Adjust `deploy.*.yml` in the `services:` section:

```yaml
services:
...
    redis-gui:
        engine: redis-commander
        endpoints:
            {custom_endpoint}: //redis-commander.spryker.local:
```

2. Adjust hosts file, if `{custom_endpoint}` aren't ending on `.localhost`:
```bash
echo "127.0.0.1 {custom_endpoint}" | sudo tee -a /etc/hosts
```


3. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

## MailHog

[MailHog](https://github.com/mailhog/MailHog) is a mail catcher service that is used with Spryker in Docker for Demo and Development environments. Developers use this email testing tool to catch and show emails locally without an SMTP (Simple Mail Transfer Protocol) server.

With the MailHog service, developers can:

* configure an application to use MailHog for SMTP delivery;
* view messages in the web UI or retrieve them via JSON API.

:::(Info) ()
By default the following applies:
*  `http://mail.spryker.local/` is used to see incoming emails.
* Login is not required
:::
### Configuration

1. Adjust `deploy.*.yml` in the `services:` section to specify a custom endpoint:
```yaml
services:
        ...
        mail_catcher:
                engine: mailhog
                endpoints:
                          {custom_endpoint}:
```
2. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

## Mailpit

[Mailpit](https://github.com/axllent/mailpit) is a mail catcher service that is used with Spryker in Docker for Demo and Development environments. Developers use this email testing tool to catch and show emails locally without an SMTP (Simple Mail Transfer Protocol) server.

With the Mailpit service, developers can:

* configure an application to use Mailpit for SMTP delivery;
* view messages in the web UI or retrieve them via JSON API.

:::(Info) ()
By default the following applies:
*  `http://mail.spryker.local/` is used to see incoming emails.
* Login is not required
  :::
### Configuration

1. Adjust `deploy.*.yml` in the `services:` section to specify a custom endpoint:
```yaml
services:
        ...
        mail_catcher:
                engine: mailpit
                endpoints:
                          {custom_endpoint}:
```
2. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

## Blackfire
[Blackfire](https://blackfire.io/) is a tool used to profile, test, debug, and optimize performance of PHP applications. It gathers data about consumed server resources like memory, CPU time, and I/O operations. The data and configuration can be checked via Blackfire web interface.

### Configuration

Follow the steps to enable Blackfire:

1. Adjust `deploy.*.yml` in the `image:` section to enable the Blackfire PHP extension:

```yaml
image:
    tag: spryker/php:8.3 # Use the same tag you had in `image:`
    php:
        ...
        enabled-extensions:
            - blackfire
```

2. Adjust `deploy.*.yml` in the `services:` section to configure Blackfire client:

```yaml
services:
    ...
    blackfire:
        engine: blackfire
        server-id: {server_id}
        server-token: {server_token}
        client-id: {client_id}
        client-token: {client-token}
```

3. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

### Alternative Configuration

Use the following configuration if you are going to change server or client details often, or if you don’t want to define them in your deploy file.

Follow the steps to enable Blackfire:

1. Adjust `deploy.*.yml` in the `image:` section to enable the Blackfire PHP extension:

```yaml
image:
    tag: spryker/php:8.3 # Use the same tag you had in `image:`
    php:
        ...
        enabled-extensions:
            - blackfire
```

2. Adjust `deploy.*.yml` in the `services:` section to enable Blackfire service:

```yaml
services:
    ...
    blackfire:
        engine: blackfire
```

3. Pass Blackfire client details:

```bash
 BLACKFIRE_CLIENT_ID={client_id} BLACKFIRE_CLIENT_TOKEN={client-token} docker/sdk cli
 ```

4. Pass Blackfire server details:

```bash
BLACKFIRE_SERVER_ID={client-token} BLACKFIRE_SERVER_TOKEN={server_token} docker/sdk up
```

:::(Warning) (Note)
You can pass the server details only with the `docker/sdk up` command.
:::

5. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

It is not obligatory to pass all the details as environment variables or define all the details in the deploy file. You can pass the details in any combination.

## New Relic

[New Relic](https://newrelic.com/) is a tool used to track the performance of services and the environment to quickly find and fix issues.

The solution consists of a client and a server. The client is used to collect data about applications in an environment and send it to the server for further analysis and presentation. The server is used to aggregate, analyse, and present the data.

### Prerequisites

* Access to New Relic with an APM account.
* Local: [New Relic license key](https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/).
* The New Relic module.

Spryker provides its own New Relic licenses for use with its PaaS environments. A New Relic license key is only required if you wish to set up your own local monitoring.

### Install the New Relic module

While most environments come with New Relic already available, you may need to add the module to your project. Add the module to your `composer.json`:

```bash
composer require spryker-eco/new-relic
```

### SCCOS: Configure New Relic

1. Adjust `deploy.*.yml` in the `image:` section:

```yaml
image:
    tag: spryker/php:7.4 # the image tag that has been previously used in `image`
    php:
        ...
        enabled-extensions:
            ...
            - newrelic
```

2. Push and deploy the changes using one of the following guides:

  * [Deploying in a staging environment](https://docs.spryker.com/docs/cloud/dev/spryker-cloud-commerce-os/deploying-in-a-staging-environment.html)
  * [Deploying in a production environment](https://docs.spryker.com/docs/cloud/dev/spryker-cloud-commerce-os/deploying-in-a-production-environment.html)



3. Submit an infrastructure change request via the [Support Portal](https://docs.spryker.com/docs/scos/user/intro-to-spryker/support/how-to-use-the-support-portal.html).
  We will confirm that a New Relic APM account is available for you and ensure that the correct application naming convention is set up to cascade to the appropriate APM.

Once New Relic is enabled, in the New Relic dashboard, you may see either `company-staging-newrelic-app` or `YVES-DE (docker.dev)`. New Relic displays these APM names by the application name setup in the configuration files.

![screenshot](https://lh3.googleusercontent.com/drive-viewer/AJc5JmRPsydm6Ds2eRmKS_lMRNjBnqhBLsvtN_ul_R1EMO7Z4pj74Mbpw3kMdAnjH6gIwLt9cvOqLcI=w1920-h919)


{% info_block infoBox %}

If you update the name of an application, [contact support](https://docs.spryker.com/docs/scos/user/intro-to-spryker/support/how-to-use-the-support-portal.html) to update the changes in your APM.

{% endinfo_block %}



### Local: Configure New Relic

1. In `deploy.*.yml`, adjust the `docker` section:

```yaml
docker:
    newrelic:
        license: {new_relic_license}
    distributed tracing:
            enabled: true
```

2. In the `deploy.*.yml`, adjust the `image` section:

```yaml
image:
    tag: spryker/php:7.4 # the image tag that has been previously used in `image`
    php:
        ...
        enabled-extensions:
            ...
            - newrelic
```

3. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```


### Configure YVES, ZED, and GLUE as separate APMs

By default, in the New Relic dashboard, the APM is displayed as `company-staging-newrelic-app`. To improve visibility, you may want to configure each application as a separate APM. For example, `YVES-DE (docker.dev)`.

To do it, adjust the Monitoring service in `src/Pyz/Service/Monitoring/MonitoringDependencyProvider.php`:

```php
<?php declare(strict_types = 1);

/**
 * This file is part of the Spryker Commerce OS.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace Pyz\Service\Monitoring;

use Spryker\Service\Monitoring\MonitoringDependencyProvider as SprykerMonitoringDependencyProvider;
use SprykerEco\Service\NewRelic\Plugin\NewRelicMonitoringExtensionPlugin;

class MonitoringDependencyProvider extends SprykerMonitoringDependencyProvider
{
    /**
     * @return \Spryker\Service\MonitoringExtension\Dependency\Plugin\MonitoringExtensionPluginInterface[]
     */
    protected function getMonitoringExtensions(): array
    {
        return [
            new NewRelicMonitoringExtensionPlugin(),
        ];
    }
}
```

{% info_block infoBox %}

* Some builds have the Monitoring service built into the Yves application. If `src/Pyz/Service/Monitoring/MonitoringDependencyProvider.php` does not exist, you may want to check `src/Pyz/Yves/Monitoring/`.

* If the class is missing from the Monitoring service, create it.


{% endinfo_block %}



With `new \SprykerEco\Service\NewRelic\Plugin\NewRelicMonitoringExtensionPlugin()` being returned with the `getMonitoringExtensions()` function, the Monitoring class includes New Relic. Now applications are displayed as separate APMs, and an appropriate endpoint or class is displayed with each transaction.

![screenshot](https://lh3.googleusercontent.com/drive-viewer/AJc5JmTs7PzBBgaotIid707cuXeru3hc5L6PZv9a_zQAyDMhp2FWKiCSTc2kmqHCaLVsBtjIcoUVYKY=w1920-h919)

4. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

## Webdriver
PhantomJS is provided as a webdriver service by default, but you can switch to ChromeDriver as described below.


### ChromeDriver

[ChromeDriver](https://chromedriver.chromium.org/) is a thin wrapper on WebDriver and [Chromium](https://chromedriver.chromium.org/) headless browser. It is used for automating web page interaction, JavaScript execution, and other testing-related activities. It provides full-control API to make end-to-end testing flexible and comfortable.


#### Configuration
To enable Chromedriver, adjust `deploy.*.yml` as follows:

```yaml
services:
    webdriver:
        engine: chromedriver
```


### PhantomJS

[PhantomJS](https://phantomjs.org/) is a headless browser for automating web page interaction. It ships with a WebDriver based on [Selenium](https://www.selenium.dev/).

#### Configuration

To enable PhantomJS, adjust `deploy.*.yml` as follows:

```yaml
services:
    webdriver:
        engine: phantomjs
```


## Dashboard

Dashboard is a tool that helps to monitor logs in real time. You can monitor logs in all or a particular container.


### Configuration

1. Adjust your `deploy.*.yml` as follows:

```yaml
dashboard:
        engine: dashboard
        endpoints:
            {custom_endpoint}:
```

2. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

## Tideways

[Tideways](https://tideways.com/) is an application profiler used for testing and debugging. Its main functions are profiling, monitoring, and exception tracking.


### Configuration

1. Adjust your `deploy.*.yml` as follows:

```yaml
tideways:
    apikey: {tideways_api_key}
    environment-name: {tideways_environment_name}
    cli-enabled: {true|false}
```

2. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

## Local OpenTelemetry Stack

The Local OpenTelemetry Stack is a powerful tool designed for real-time monitoring of Application Performance Monitoring (APM) locally. It allows you to track APM traces across all containers or specific ones running PHP applications.

This stack integrates the following containers into your local environment:
* tempo-init
* tempo
* collector
* prometheus
* grafana

### Configuration

1. Adjust your `deploy.*.yml` as follows:

```yaml
    grafana:
        engine: otel-stack
        endpoints:
            grafana:
```

2. Bootstrap the docker setup and rebuild the application:
```bash
docker/sdk boot deploy.*.yml &&\
docker/sdk up
```

## Custom Services

Custom services allow you to integrate any Docker-based service into your Spryker environment. This is useful for adding third-party services like AWS LocalStack, MinIO, Kafka, etc.

:::(Warning) (Local Development Only)
**Important:** Custom services are **only available in local development environments**. They will **NOT** be automatically propagated or available in Cloud environments (staging, production). Custom services are designed for local development, testing, and mocking purposes only.
:::

### Use Cases

Custom services support two primary use cases:

1. **Pre-built Docker images** - Use existing images from Docker Hub or private registries
2. **Custom Dockerfile builds** - Build services from your own Dockerfiles with project-specific configurations

### Configuration Options

| Option | Required | Description |
|--------|----------|-------------|
| `engine` | Yes | Must be set to `custom` |
| `image` | No* | Docker image to use (e.g., `nginx:alpine`) |
| `build` | No* | Build configuration for custom Dockerfile |
| `build.context` | Yes** | Build context path or service name |
| `build.dockerfile` | No | Dockerfile name (defaults to `Dockerfile`) |
| `build.args` | No | Build arguments as key-value pairs |
| `endpoints` | No | HTTP/TCP endpoints for the service |
| `port` | No | Internal port the service listens on |
| `environment` | No | Environment variables |
| `volumes` | No | Volume mounts |
| `command` | No | Override container command |
| `healthcheck` | No | Health check configuration |
| `depends_on` | No | Service dependencies |
| `persistent` | No | Enable persistent volume (default: `true`) |

\* Either `image` or `build` must be specified  
\** Required when using `build`

### Use Case 1: Pre-built Docker Image

Use this approach when you want to run an existing Docker image without modifications.

#### Example: AWS LocalStack

```yaml
services:
    localstack:
        engine: custom
        image: localstack/localstack:latest
        endpoints:
            localstack.spryker.local:
        port: 4566
        environment:
            SERVICES: s3,sqs,lambda,dynamodb,sns,ses
            DEBUG: "1"
        volumes:
            - localstack-data:/var/lib/localstack
```

### Use Case 2: Custom Dockerfile Build

Use this approach when you need to build a custom Docker image with project-specific configurations.

#### Project Structure

Place your Dockerfile and related files in the `config/deploy-templates/services/` directory:

```
project-root/
├── config/
│   └── deploy-templates/
│       ├── services/                  # Service contexts for custom services
│       │   ├── my-service/
│       │   │   ├── Dockerfile
│       │   │   └── config.yml (optional)
│       │   └── localstack/            # Example: LocalStack configuration
│       │       ├── localstack.conf
│       │       └── init-aws.sh
├── deploy.*.yml
└── ...
```

The `config/deploy-templates/services/` directory contents are automatically copied to the deployment context during `docker/sdk boot`.

#### Example: LocalStack with Configuration Files

:::(Warning) (Cloud Deployment)
**Remember:** This example and all custom services are for **local development only**. They will **NOT** be deployed to Cloud environments automatically. Configure Cloud services separately through your infrastructure.
:::

Here's a complete example of a custom service with configuration files:

**Project structure:**
```
config/deploy-templates/services/localstack/
├── localstack.conf    # LocalStack configuration
└── init-aws.sh        # Initialization script
```

**Configuration file (`localstack.conf`):**
```ini
# LocalStack Configuration
[default]
# Services to enable
services = s3,sqs,lambda,dynamodb,sns,ses

# Debug mode
debug = 1

# Data directory
data_dir = /var/lib/localstack/data

# Persistence
persistence = 1

# Lambda
lambda_executor = local
lambda_runtime_executor = docker

# S3
s3_fix_content_type = 1
```

**Initialization script (`init-aws.sh`):**
```bash
#!/bin/bash
# LocalStack initialization script
set -e

echo "Initializing LocalStack..."

# Wait for LocalStack to be ready
until aws --endpoint-url=http://localhost:4566 s3 ls; do
  echo "Waiting for LocalStack..."
  sleep 2
done

echo "LocalStack is ready!"

# Create S3 buckets
aws --endpoint-url=http://localhost:4566 s3 mb s3://test-bucket || true

# Create SQS queues
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name test-queue || true

# Create DynamoDB tables
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name test-table \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST || true

echo "LocalStack initialization complete!"
```

**Deploy file configuration (`deploy.*.yml`):**
```yaml
services:
    localstack:
        engine: custom
        image: localstack/localstack:latest
        endpoints:
            localstack.spryker.local:
        port: 4566
        environment:
            SERVICES: s3,sqs,lambda,dynamodb,sns,ses
            DEBUG: "1"
            DATA_DIR: /var/lib/localstack/data
            LOCALSTACK_CONFIG_FILE: /etc/localstack/localstack.conf
        volumes:
            - localstack-data:/var/lib/localstack
            - ./${DEPLOYMENT_PATH}/context/localstack/localstack.conf:/etc/localstack/localstack.conf:ro
            - ./${DEPLOYMENT_PATH}/context/localstack/init-aws.sh:/etc/localstack/init-aws.sh:ro
```

The configuration files are automatically copied from `config/deploy-templates/services/localstack/` to the deployment context and mounted into the container.

#### Configuration

```yaml
services:
    my-service:
        engine: custom
        build:
            context: my-service        # Auto-resolves to context/my-service/
            dockerfile: Dockerfile     # Optional, defaults to "Dockerfile"
            args:                      # Optional build arguments
                BUILD_VERSION: "1.0.0"
                NODE_ENV: production
        endpoints:
            my-service.spryker.local:
        port: 8080
        environment:
            APP_ENV: development
            LOG_LEVEL: debug
        volumes:
            - my-service-data:/data
        healthcheck:
            test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
            interval: 30s
            timeout: 10s
            retries: 3
```

#### Build Context Resolution

The `build.context` value is automatically resolved:

| Value | Resolves To |
|-------|-------------|
| `my-service` | `./${DEPLOYMENT_PATH}/context/my-service/` |
| `context/my-service` | `./${DEPLOYMENT_PATH}/context/my-service` |

#### Example Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 8080

CMD ["node", "server.js"]
```

### Endpoint Configuration

#### HTTP Endpoints

HTTP endpoints are automatically proxied through the Nginx gateway:

```yaml
endpoints:
    my-service.spryker.local:
```

Access via: `http://my-service.spryker.local`

#### TCP Endpoints

For services that require direct TCP access (databases, message brokers):

```yaml
endpoints:
    localhost:9092:
        protocol: tcp
```

Access via: `localhost:9092`

### Health Checks

Configure health checks to ensure service availability:

```yaml
healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
    interval: 30s
    timeout: 10s
    retries: 3
```

Or using shell commands:

```yaml
healthcheck:
    test: ["CMD-SHELL", "pg_isready -U postgres || exit 1"]
    interval: 10s
    timeout: 5s
    retries: 5
```

### Volumes

#### Named Volumes (Persistent)

```yaml
volumes:
    - my-service-data:/data
```

Named volumes are automatically declared and persisted across container restarts.

#### Bind Mounts

```yaml
volumes:
    - ./config/my-service:/app/config:ro
```

### Disabling Persistent Storage

To disable the default persistent volume:

```yaml
my-service:
    engine: custom
    image: nginx:alpine
    persistent: false
```

### Applying Changes

After modifying custom services configuration:

```bash
docker/sdk boot deploy.*.yml
docker/sdk up --build
```

### Troubleshooting

#### Service Not Accessible

1. Check if the service is running: `docker/sdk ps`
2. Check service logs: `docker/sdk logs my-service`
3. Verify endpoint configuration and `port` value matches the service's listening port

#### Build Fails

1. Ensure Dockerfile exists in `config/deploy-templates/services/{service-name}/`
2. Check build context path is correct
3. Review build logs for errors

#### Volume Errors

1. For "undefined volume" errors, ensure volume names don't contain special characters
2. Named volumes are automatically declared; bind mounts must reference existing paths
