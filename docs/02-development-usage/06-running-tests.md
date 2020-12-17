This document is a draft. See [Docker SDK](https://documentation.spryker.com/docs/docker-sdk) for official documentation.

## Description
Read the description below and, in the *Structure* section, fill out the document by answering the questions directly.
We may have added some existing content and encourage you to update, remove or restructure it if needed.


> Audience:
>
> - Developers who run tests using docker/sdk.
> - Devops who set CI up using docker/sdk.
>
> Outcome:
> - You know how to run functional, API, E2E tests locally or on CI using docker/sdk.

## Outline

1. How to turn on testing mode: argument, `testing` commands.
2. How to run tests.
3. How to choose webdriver.
4. What codeception configuration should be in place.
5. Testing mode. What is the difference in comparing with usual mode.

## Structure

:::(Info)(Structure)
The structure below is just a reference. We encourage you to add subsections, change or swap the provided sections if needed.
:::


### What is a testing mode?

Docker SDK allows you to run application in an environment configured for testing.

In the testing mode, docker/sdk generates an environment file and a set of containers designed for testing. For example, the environment does not have SSL encryption, there is no scheduler container, but the webdriver container is present. 


#### How do I run the testing mode?

There are two ways to run the test mode:
* To restart all containers in the testing environment, run `docker/sdk up -t`.
* To start a new container where you can run CLI commands in the testing environment, run  `docker/sdk testing`. 

### How do I run tests?

To run tests, you need to run the `codecept run` command in a CLI container.

There are several ways to do that:
* if you run `docker/sdk up` with `-t` flag, you need to go in CLI container(`docker/sdk cli`) and run test(`codecept run`);
* if you start CLI container in testing mode(`docker/sdk testing`), you need is run `codecept run`;
* you can run `docker/sdk testing codecept run`.

### How do I choose a webdriver?

To choose a webdriver, update your `deploy.*.yml`.

Chromedriver is the default webdriver shipped with docker/sdk. 

The Chromedriver configuration looks as follows in the deploy file:
```yaml
services:
    webdriver:
        engine: chromedriver
```        

See [webdriver:](https://documentation.spryker.com/docs/deploy-file-reference-10#webdriver-) to learn more about webdriver configuration in the deploy file. 

### How do I configure Codeception?

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

