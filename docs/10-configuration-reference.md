# Configuration reference

This document is a quick reference for the most common configuration options of the Docker SDK.

The configuration parameters in this document are examplary. You may need to adjust them per your project requirements.



## Сonfiguring Opcache

To configure Opcache, adjust `deploy.*.yml` as follows:

```yaml
image:
    tag: spryker/php:8.3
    php:
        ini:
            "opcache.revalidate_freq": 0
            "opcache.enable_cli": 0
            "opcache.enable": 0
            ...
```

## Defining a memory limit

To define a memory limit, adjust `deploy.*.yml` as follows:

```yaml
image:
    tag: spryker/php:8.3
    php:
        ini:
            "memory_limit": 512m
```

## Providing custom environment variables to Spryker applications

To provide custom environment variables to Spryker applications, adjust `deploy.*.yml` as follows:

```yaml
image:
    tag: spryker/php:8.3
    environment:
        MY_CUSTOM_ENVIRONMENT_VARIABLE: 1
        ...
```

:::(Info) ()
The environment variables defined in `environment:` are embedded into all application images.
:::

## Increasing maximum upload size

To increase maximum upload size, update `deploy.*.yml` as follows:

1. In Nginx configuration, update maximum request body size:
```yaml
...
    applications:
      backoffice:
        application: backoffice
        http:
          max-request-body-size: {request_body_size_value}
        ...
```

2. Update PHP memory limit:

```yaml
image:
    ...
    php:
        ini:
            memory_limit: {memroy_limit_value}
            ...
```


## Checking the deployed build

Every application endpoint serves `/build.json` (from the frontend container) and `/build.php` (from the application container). They return the deployed build hash and build timestamp:

```json
{"self":"application","build":"{build_hash}","stamp":"{build_timestamp}"}
```

The endpoints need no configuration and are not public. They respond only to requests that did not pass through a public network: the client address, every `X-Forwarded-For` entry, and `X-Real-IP` must be private (`127.0.0.0/8`, `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`). Such requests skip the endpoint's `auth:`. All other requests are rejected with `403`, even with valid basic auth credentials.

* Locally, open `http://{endpoint host}/build.json` or `http://{endpoint host}/build.php` in a browser or run `curl` against it.
* In AWS, send the request from inside the VPC directly to the frontend, for example, from the frontend container:

```bash
curl -s -H 'Host: {endpoint host}' http://127.0.0.1/build.json
curl -s -H 'Host: {endpoint host}' http://127.0.0.1/build.php
```

Requests to the public endpoint URL, including the ones sent from AWS through the NAT gateway, are rejected.
