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

It's a mode in which you can check that your system functional correctly

#### How is the testing mode different from the usual mode?

Starts a new webdriver container where you can run cli commands in testing environment.

#### How do I turn on the testing mode?

```bash
docker/sdk up -t
```

```bash
docker/sdk testing
```

Note: Problems, check your webdriver container.

### How do I run tests?

Locally

CI


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


