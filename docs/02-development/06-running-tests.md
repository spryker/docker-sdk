# Running tests

This document describes how to run tests in different ways.

## What is a testing mode?

Docker SDK allows you to run an application in an environment configured for testing.

In the testing mode, docker/sdk set of containers configured for testing. For example:
1. background jobs are disabled;
2. the webdriver container is present.



## Running tests in the testing mode

To run tests, you need to run Codeception in a CLI container.

There are several similar ways to do that. Use the most suitable way for you.

### Running tests in a dedicated testing container

To run tests in a dedicated testing container:

1. Start a new container in testing mode:
```bash
docker/sdk testing
```

2. Run Codeception:
```bash
codecept run
```

### Running tests in a dedicated testing container with a single command

To run tests in a dedicated testing container with a single command, run `docker/sdk testing codecept run`.

The command runs tests as follows:

1. Start a new container in testing mode.
2. Run Codeception.
3. Stop the container.

### Running tests with all containers in the testing mode

To run tests with all containers in testing mode:

1. Restart all containers in testing mode:

```bash
docker/sdk up -t
```
2. Switch to the CLI container:
```bash
docker/sdk testing
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

See [webdriver:](99-deploy.file.reference.v1.md#webdriver-) to learn more about webdriver configuration in the deploy file.

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
