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

Docker SDK provides you to run application in a specially prepared environment where you can check that your system functional correctly

#### How is the testing mode different from the usual mode?

By default, testing mode different from usual is generates specific env file with variables(e.g. without SSL) and container set(e.g. with webdriver and without a scheduler).

#### How do I turn on the testing mode?

You have two ways of running a testing mode:
* running `docker/sdk up` with `-t` flag, this command restarts all your containers in the testing environment;
* running  `docker/sdk testing`, starts a new container where you can run CLI commands in the testing environment.

### How do I run tests?

The test running process in docker doesn't have any difference from local environment. All you need is to run `codecept run` in CLI container.

You have a few ways:
* if you run `docker/sdk up` with `-t` flag, you need to go in CLI container(`docker/sdk cli`) and run test;
* if you start CLI container in testing mode(`docker/sdk testing`), you need is run `codecept run`;
* you can run `docker/sdk testing codecept run`.

### How do I choose a webdriver?

docker/sdk uses Chromedriver as the default one.

Chromedriver (Headless Chromium).

A modern and productive solution that allows you to directly use the Chrome / Chromium functionality

Pros:
* Higher execution speed and less memory consumption in comparison with PhantomJS;
* Supported by Google;
* Uses driver with Codeception out of the box;
* No need for additional development activities;
* Open-source solution.

Cons:
* Emulation capabilities limited to one browser.

PhantomJS (Scriptable Headless Browser).

Pros:
* Default driver with Codeception

Cons:
* Not supportable anymore.

For choosing webdriver, you need to update your `deploy.yml`

```yaml
services:
    webdriver:
        engine: chromedriver
```        

### How do I configure codeception?
1. Prepare required environment variables:
```yaml
SPRYKER_TESTING_ENABLED: false
SPRYKER_TEST_WEB_DRIVER_HOST: '0.0.0.0'
SPRYKER_TEST_WEB_DRIVER_PORT: '4444'
SPRYKER_TEST_IN_BROWSER: 'chrome'
SPRYKER_TEST_BROWSER_BIN: '/usr/local/bin/chrome'
SPRYKER_TEST_WEB_DRIVER_BIN: 'vendor/bin/chromedriver'
```

2. Configure codeception.*.yml:
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

