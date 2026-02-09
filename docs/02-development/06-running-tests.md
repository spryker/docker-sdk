# Running tests

This document describes how to run tests in different ways.

## What is a testing mode?

The Docker SDK lets you run applications in an environment configured for running tests.

In the testing mode, you can run tests in isolation, with full control of the system tested and all needed tooling in place. Once you activate the testing mode, the following happens:
1. The scheduler is enabled. Background jobs are stopped for preserving data consistency and full isolation.
2. The webdriver is enabled.


## Activating the testing mode and running tests

You can activate the testing mode in one of the following ways:

* Switch a running environment into the testing mode without rebuilding containers.
* Rebuild containers and run or restart an environment with the testing mode activated.

## Testing with multiple stores

When working with a multistore setup, you can configure the Docker SDK to support testing across multiple stores. This allows you to run tests for each store without creating separate deployment files.

### Configuring multiple stores for testing

In your `deploy.yml` file, specify the stores you want to test:

```yaml
docker:
    testing:
        stores: DE,AT
```

### Running tests for a specific store

When multiple stores are configured, specify which store to use by setting the `APPLICATION_STORE` environment variable:

```bash
# Run tests for DE store
APPLICATION_STORE=DE docker/sdk testing

# Run tests for AT store
APPLICATION_STORE=AT docker/sdk testing

# Run a specific test command for a store
APPLICATION_STORE=DE docker/sdk testing codecept run
```

If `APPLICATION_STORE` is not specified, the system will use the first store from the configured list.

### Activating the testing mode in a running environment

1. Activate the testing mode in a running environment and enter the CLI container:
```bash
docker/sdk testing
```

2. In the CLI container, run Codeception:
```bash
codecept run
```
{% info_block infoBox "" %}

Same as other CLI commands, you can run the preceding commands as a single command: `docker/sdk testing codecept run`.

{% endinfo_block %}


### Running or restarting an environment in the testing mode

1. Restart all containers in the testing mode:

```bash
docker/sdk up -t
```

2. Switch to the CLI container:
```bash
docker/sdk cli -t
```

3. Run Codeception:
```bash
codecept run
```


## Running a specific category of tests

There are three categories of Spryker tests:
* Acceptance
* Functional
* Api

To run a specific category, run `codecept` with the respective configuration file:
```bash
codecept run -c codeception.{acceptance|functional|api}.yml
```

### Running a group of tests

To run one or more groups of tests, run `codecept run -g {Tax} -g {Customer}`.

### Excluding a group of tests

To exclude one or more groups of tests, run `codecept run -x {Tax} -x {Customer}`.


## Configuring a webdriver

To choose a webdriver, update `deploy.*.yml`.

Chromedriver is the default webdriver shipped with Docker SDK.

The Chromedriver configuration looks as follows in the deploy file:
```yaml
services:
    webdriver:
        engine: chromedriver
```        

See [webdriver:](../07-deploy-file/02-deploy.file.reference.v1.md#webdriver-) to learn more about webdriver configuration in the deploy file.

## Configure Codeception

To configure Codeception:

1. Prepare required environment variables:
```yaml
SPRYKER_TESTING_ENABLED: false
SPRYKER_TEST_WEB_DRIVER_HOST: '0.0.0.0'
SPRYKER_TEST_WEB_DRIVER_PORT: '4444'
SPRYKER_TEST_IN_BROWSER: 'chrome'
SPRYKER_TEST_BROWSER_BIN: '/usr/local/bin/chrome'
SPRYKER_TEST_WEB_DRIVER_BIN: 'vendor/bin/chromedriver'
```

2. Configure `codeception.*.yml`:
```yaml
extensions:
    enabled:
        - \SprykerTest\Shared\Testify\Helper\WebDriverHelper
        - \SprykerTest\Shared\Testify\Helper\SuiteFilterHelper
    config:
        \SprykerTest\Shared\Testify\Helper\WebDriverHelper:
            suites: ['Presentation']
            path: "%SPRYKER_TEST_WEB_DRIVER_BIN%"
            whitelisted-ips: ''
            webdriver-port: "%SPRYKER_TEST_WEB_DRIVER_PORT%"
            url-base: "/wd/hub"
            remote-enable: "%SPRYKER_TESTING_ENABLED%"
            host: "%SPRYKER_TEST_WEB_DRIVER_HOST%"
            browser: "%SPRYKER_TEST_IN_BROWSER%"
            capabilities:
                "goog:chromeOptions":
                    args: ["--headless", "--no-sandbox", "--disable-dev-shm-usage"]
                    binary: "%SPRYKER_TEST_BROWSER_BIN%"
        \SprykerTest\Shared\Testify\Helper\SuiteFilterHelper:
            inclusive:
                - Presentation

params:
    - tests/default.yml
    - env
```

## Stopping the testing mode

Once you've finished running tests, you can switch back to the development mode:

```bash
docker/sdk start
```

This stops or removes the webdriver, runs the scheduler, and deactivates the testing mode.
