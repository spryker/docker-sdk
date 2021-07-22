# Configuring debugging

This document describes how to configure debugging of Spryker in Docker.

[Xdebug](https://xdebug.org) is the default debugging tool for Spryker in Docker. To enable Xdebug, run the command:
```bash
docker/sdk {run|start|up} -x
```

## Configuring PhpStorm for Xdebug

This section describes how to configure Phpstorm to be used with Xdebug.

### PhpStorm configuration prerequisites

Install the required software:

1. [Install PhpStorm](https://www.jetbrains.com/phpstorm/download/#section=mac), [Early Access Program](https://www.jetbrains.com/phpstorm/nextversion/) preferred.
You can download PHPStorm through the [Jetbrains Toolbox](https://www.jetbrains.com/toolbox-app/).
2. [Install Xdebug](https://xdebug.org/docs/install).
3. Optional: install the [Xdebug browser extension](https://www.jetbrains.com/help/phpstorm/2021.1/browser-debugging-extensions.html). In the extension settings, for **IDE key**, enter `PHPSTORM`.

### Configuring Xdebug

To configure Xdebug in PhpStorm:

1. Go to **Preferences** > **PHP** > **Debug**.

2. In the *Xdebug* section:

      1. Depending on your requirements, for **Debug port**, enter one or more ports.
        For example, to support Xdebug 2 and 3, enter `9000,9003`.
      2. Select the **Can accept external connections** checkbox.
      3. Clear the **Force break at first line when no path mapping specified** and **Force break at first line when a script is outside the project** checkboxes.

![xdebug-configuration](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Docker+SDK/Configuring+debugging+in+Docker/xdebug-configuration.png)

3. In the *External connections* section:

      1. For **Max. simultaneous connection**, select **5**.
      2. Clear the **Ignore external connections through unregistered server configurations** and **Break at first line in PHP scripts** checkboxes.

![image 2](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Docker+SDK/Configuring+debugging+in+Docker/xdebug-external-connections-configuration.png)

### Configuring servers
To configure servers:
1. Go to **Preferences** > **PHP** > **Servers**.

2. Add a server:

    1. For **Name**, enter *spryker*.
    2. For **Host**, enter *spryker*.
    3. For **Port**, enter `80`.
    4. In the **Debugger** drop-down menu, select **Xdebug** .
    5. Select the **Use path mappings** checkbox.
    6. Set the absolute path to the `/data` folder on the server for the folder with your Spryker project files.
    ![Servers config](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Docker+SDK/Configuring+debugging+in+Docker/servers-confg.png)


### Troubleshooting the debugging configuration in PhpStorm

**when**
A breakpoint does not work.

**then**

1. In PhpStorm, go to **Preferences** > **PHP** > **Debug**.
2. Select the **Break at first line in PHP scripts** checkbox.
3. Rerun or refresh your application.
      The app should break at the `index.php` and open a debugger pane in the IDE:
      ![debugger-pane](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Docker+SDK/Configuring+debugging+in+Docker/debugger-pane.png)
4. Re-try your breakpoints.


## Configuring VSCode for Xdebug

This section describes how to configure Visual Studio Code (VSCode) to be used with Xdebug.


### VScode configuration prerequisites

Install the required software:

1. [Install VScode](https://code.visualstudio.com/download), the [Insiders version](https://code.visualstudio.com/insiders/) preferred.
2. [Install Xdebug](https://xdebug.org/docs/install).
3. [Install PHP Debug Extension](https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug).

## Set up a new Launch.json

Set up a new `Launch.json`:

```
{
    "version": "0.2.0",
    "configurations": [

        {
            "name": "Listen for XDebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "runtimeExecutable": "/absolute/path/php/bin",
            "pathMappings": {
                "/data": "/local/absolute/path",
            },
            "log": true,
            "xdebugSettings": {
                "max_data": 65535,
                "show_hidden": 1,
                "max_children": 100,
                "max_depth": 5
            }
        },
    ]
}
```


## Avoiding timeouts

The default Zed Request timeout is 60 seconds. Debugging requests often take more than 60 seconds to complete. In this case, a browser stops the connection.

To avoid Zed Request timeouts, adjust your configuration as follows:
```php
$config[ZedRequestConstants::CLIENT_OPTIONS] = [
    'timeout' => 300,
];
```

300 seconds should suit most cases, but you can increase it or even make it unlimited by defining the value as `0`.

:::(Warning) (Unlimited timeout)
If you set unlimited timeout, this affects all Zed Requests, not only debugging ones.
:::


## Switching to the debugging mode
There are several ways to switch to the debugging mode:

* To debug a web application, pass the `XDEBUG_SESSION` cookie with a string value. If you are using the Xdebug helper browser extension, in the extension menu, select **debug**.
* To run all applications in the debugging mode, run `docker/sdk {run|start|up} -x`.
* To debug a console command in cli, run it with the `-x` option.

## Debugging with Xdebug

This section describes how to debug with Xdebug.

### Debbugging applications with Xdebug

To debug an application:

1. Make a breakpoint:
![Breakpoint](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Docker+SDK/Configuring+debugging+in+Docker/breakpoint.png)

2. Select *Start listening* ![Start listening](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Debugging+Setup+in+Docker/start-listening.png).

3. Open the application in a browser.

4. Navigate to the action you have configured the breakpoint for in step 1. The debugging process should be running in the IDE:
![Debug process](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Docker+SDK/Configuring+debugging+in+Docker/debug-process.png)

### Debugging console commands and tests with Xdebug

To debug a console command or a test in a debugging mode, run it with the `-x` option.

Find several examples below:
* `docker/sdk cli -x`
* `docker/sdk cli -x console queue:worker:start`
* `docker/sdk console -x queue:worker:start`
* `docker/sdk testing -x codecept run -codeception.yml`
