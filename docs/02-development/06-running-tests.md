# Running tests

This document describes how to run tests in different ways.

## What is a testing mode?

Docker SDK allows you to switch the application into the special mdoe, optimised for running your tests.

The aim of the testing mode - is to allow you running tests in isolation, having a full control on the system under test and have all needed tooling in place. Once activating testing mode, the following happens:
1. CLI, applicatoin and webserver contaienrs are switched to the "testing mode";
2. Background jobs are disabled;
3. The webdriver container for the end-to-end tests is created (if not yet) and launched.


## Activating testing mode and running your tests

Your Codeception tests will be executed in the CLI container with the testing mode activated. You can acieve that by either switching your running environment (w.o. rebuilding containers) into the testing mode, or run/restart your environment with testing mode activated (with rebuilding contaienrs).

### Activating testing mode on your running environment

To activate the testing mode on your running environment and enter CLI container:
```bash
docker/sdk testing
```

Now, in the CLI container, you can run Codeception:
```bash
codecept run
```
Same as with other CLI commands, you can run the above in a single command, e.g. `docker/sdk testing codecept run`.

### Run / resrart your environment in a testing mode

1. Restart all containers in testing mode:

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

## Stopping the testing mode

Once you're done with running your tests, you can get back to the development mode by simply runing

```bash
docker/sdk start
```

This will stop/remove the webdriver, run the scheduler and deactivate testing mode.
