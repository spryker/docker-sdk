> Audience:
>
> - Everyone who wants to know how to configure the Docker SDK.
>
> Outcome:
> - You have a handbook with configuration instructions for common cases.


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
