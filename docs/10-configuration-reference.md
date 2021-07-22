# Configuration reference

This document is a quick reference for the most common configuration options of the Docker SDK.

The configuration parameters in this document are examplary. You may need to adjust them per your project requirements.



## Сonfiguring Opcache

To configure Opcache, adjust `deploy.*.yml` as follows:

```yaml
image:
    tag: spryker/php:7.3
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
    tag: spryker/php:7.3
    php:
        ini:
            "memory_limit": 512m
```

## Providing custom environment variables to Spryker applications

To provide custom environment variables to Spryker applications, adjust `deploy.*.yml` as follows:

```yaml
image:
    tag: spryker/php:7.3
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
