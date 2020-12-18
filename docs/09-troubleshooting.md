This document is a draft. See [Docker SDK](https://documentation.spryker.com/docs/docker-sdk) for official documentation.

## Description
Read the description below and, in the *Structure* section, fill out the document by answering the questions directly.
We may have added some existing content and encourage you to update, remove or restructure it if needed.

> Audience:
>
> - Everybody who have a problem running docker/sdk locally.
>
> Outcome:
> - You may find a solution for your particular problem with docker/sdk.

## Outline

1. Copy the existing items here
2. Divide all the items by categories:
- Installation
- Running
- Debugging
- Running tests (if any)
4. Debugging troubleshooting is quite outdated and needs update.

## Important points to cover

## Structure

:::(Info)(Structure)
The structure below is just a reference. We encourage you to add subsections, change or swap the provided sections if needed.
:::

***

This document contains solutions to the most common issues related to docker/sdk.

### Troubleshooting installation

#### Docker daemon is not running

**when**
Running the `docker/sdk up` console command returns a similar error:
```bash
Error response from daemon: Bad response from Docker engine
```

**then**
1. Make sure Docker daemon is running.
2. Run `docker/sdk up` again.


#### docker-sync cannot start

**when**
Running `docker-sync clean` returns an error similar to the following:
```bash
docker: Error response from daemon: Conflict. The container name "/data-sync" is already in use by container "47dd708a7a7f9550390432289bd85fe0e4491b080748fcbba7ddb3331de2c7e7". You have to remove (or rename) that container to be able to reuse that name.
```

**then**
1. Run `docker-sync clean`.
2. Run `docker/sdk up` again.
***

**when**
You get an error similar to the following:
```bash
Unable to find image "eugenmayer/unison:hostsync_@.2' Locally
docker: Error response from daemon: manifest for eugenmayer/unison:hostsync_@.2 not found: manifest unknown: manifest unknown.
```

**then**
Update docker-sync:
```bash
gem install docker-sync
```

#### Setup of new indexes throws an exception

**when**
Running the command `setup-search-create-sources [vendor/bin/console search:setup:sources]` returns the exception:
```
Elastica\Exception\Connection\HttpException - Exception: Couldn't resolve host
in /data/vendor/ruflin/elastica/lib/Elastica/Transport/Http.php (190)
```

**then**
Increase RAM for Docker usage.


#### Vendor folder synchronization error

**when**
You get an error similar to `vendor/bin/console: not found`.

**then**
Re-build basic images, assets, and codebase:
```bash
docker/sdk up --build
```

#### An error during front end setup

**when**
The `frontend:project:install-dependencies` command returns an error similar to the following:
```
-->  DEVELOPMENT MODE
Store: US | Environment: docker
Install Project dependencies
[info] npm
[info]  WARN prepare
[info]  removing existing node_modules/ before installation
[info]
> fsevents@1.2.11 install /data/node_modules/fsevents
> node-gyp rebuild
[info] gyp
[info]  ERR! find Python
gyp ERR! find Python
[info]  Python is not set from command line or npm configuration
gyp ERR!
[info] find Python Python is not set from environment variable PYTHON
gyp ERR!
[info]  find Python checking if "python" can be used
gyp ERR!
```

**then**

1. In `deploy.*.yaml`, change the base PHP image:
```yaml
image:
    tag: spryker/php:7.3-alpine3.10
```

2. Fetch the changes and start the instance:
```bash
docker/sdk boot && docker/sdk up
```

#### Demo data was imported incorrectly

**when**
Demo data was imported incorrectly.

**then** 
Re-load demo data:
```bash
docker/sdk clean-data && docker/sdk up && docker/sdk console q:w:s -v -s
```

### Troubleshooting running applications

#### Port is already occupied on host

**when**
Running the `docker/sdk up` console command returns an error similar to the following:
```bash
ERROR: for nginx_frontend Cannot start service nginx_frontend: driver failed programming external connectivity on endpoint spryker_nginx_frontend_1 (e4fdb360f6c9a3243c0a88fa74f8d377325f65b8cd2340b2dacb51377519c1cf): Error starting userland proxy: Bind for 0.0.0.0:80: unexpected error (Failure EADDRINUSE)
```

**then**
1. Check what process occupies the port:
```bash
sudo lsof -nPi:80 | grep LISTEN
```
2. Stop the process or make it use a different port.
3. Run `docker/sdk up` again.


#### 413 Request Entity Too Large

**when**
You get the `413 Request Entity Too Large` error.

**then**
1. Increase the maximum request body size for the related application. See [Deploy File Reference - 1.0](https://documentation.spryker.com/docs/deploy-file-reference-10#groups-applications) to learn how to do that.
2. Fetch the update:
```bash
docker/sdk bootstrap
```
3. Re-build applications:
```bash
docker/sdk up
```

#### Nginx welcome page

**when**
You get the Nginx welcome page by opening an application in the browser.

**then**
1. Update the nginx:alpine image:

```bash
docker pull nginx:alpine
```

2. Re-build applications:

```bash
docker/sdk up
```

#### An application is not reachable via http

**when**
An application like Yves, Zed, or Glue is not reachable after installation.

**then**
In `deploy.*.yml`, ensure that SSL encryption is disabled:
```yaml
docker:
    ssl:
        enabled: false
```

#### Mutagen 

**when** 
You get the error: 
```bash
unable to reconcile Mutagen sessions: unable to create synchronization session (spryker-dev-codebase): unable to connect to beta: unable to connect to endpoint: unable to dial agent endpoint: unable to create agent command: unable to probe container: container probing failed under POSIX hypothesis (signal: killed) and Windows hypothesis (signal: killed)
```

**then**
1. Restart your OS.
2. If the error persists: Check [Mutagen documentation](https://mutagen.io/documentation/introduction).

### Troubleshooting debugging

**when**
Xdebug does not work.

**then**
1. Ensure that IDE is listening to the port 9000.
2. Get into any application container:
```bash
$ docker exec -i spryker_zed_1 bash
```
3. Check that the `xdebug` extension is active:
```bash
$ docker/sdk cli php -m
```
4. Check if the host is accessible from the container:
```bash
$ nc -zv ${SPRYKER_XDEBUG_HOST_IP} 9000
```

**when**
PHP `xdebug` extension is not active in CLI.

**then**
Exit the CLI session and run `docker/sdk cli -x`.

**when**
PHP `xdebug` extension is not active in the browser.

**then**
1. In `deploy.*.yml`, ensure that Xdebug is enabled:
```
```yaml
docker:
...
    debug:
      xdebug:
        enabled: true
```
2. Try the following:
    * Set the `XDEBUG_SESSION=spryker` cookie  for the request.
    * Run the following command:
    ```bash
    docker/sdk run -x
    ```

**when**
`nc` command does not give any output.

**then**
[Contact us](https://support.spryker.com/hc/en-us).


**when**
`nc` command tells that the port is opened.

**then**
1. Exit the container.
2. Check what process occupies the port by running the command:
```bash
sudo lsof -nPi:9000 | grep LISTEN
```
3. Make sure it is your IDE.
