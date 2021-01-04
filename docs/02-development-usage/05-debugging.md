> Audience:
>
> - Developers who debug using docker/sdk.
>
> Outcome:
> - You know how to debug frontend websites, API and console commands.

## Outline

1. How to switch to debugging mode: cookie, CLI or running in debug mode.
2. How to set the debugging session in PHPStorm properly.
3. Timeouts.
 - Warning: browser can stop the connection.
 - Zed Request timeout: how to manage it while debugging.
4. Link to the troubleshooting page.




This document describes how to configure debugging of Spryker in Docker.

[Xdebug](https://xdebug.org) is the default debugging tool for Spryker in Docker. To enable Xdebug, run the command:
```bash
docker/sdk {run|start|up} -x
``` 
## Configuring Xdebug in PhpStorm - required configuration

This section describes the required configuration for Xdebug in PHPStorm.

### Configuring Xdebug
To configure Xdebug in PhpStorm:
1. Go to **Preferences** > **Languages & Frameworks** > **PHP** > **Debug**.

2. In the *Xdebug* section:

      1. Depending on your requirements, change the **Debug port** value. It is set to "9000" by default.
      2. If not selected, select the **Can accept external connections** checkbox.
      3. If selected, clear the **Force break at first line when no path mapping specified** and **Force break at first line when a script is outside the project** checkboxes.

![xdebug-xdebug-configuration](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Debugging+Setup+in+Docker/xdebug-xdebug-configuration.png){height="" width=""}

3. In the *External connections* section:

      1. For **Max. simultaneous connection**, select **5**.
      2. Clear the **Ignore external connections through unregistered server configurations** and **Break at first line in PHP scripts** checkboxes.

![image 2](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Debugging+Setup+in+Docker/xdebug-external-connections-configuration.png){height="" width=""}

### Configuring servers 
To configure servers:
1. Go to **Preferences** > **Languages & Frameworks** > **PHP** > **Servers**.

2. Add a server:

    1. For **Name**, enter *spryker*.
    2. For **Host**, enter *spryker*.
    3. Select the **Use path mappings** checkbox.
    4. Set the absolute path to the `/data` folder on the server for the folder with your Spryker project files.
    ![Servers config](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Debugging+Setup+in+Docker/servers-confg.png){height="" width=""}
       

## Debugging with Xdebug

To debug an application:

1. Make a breakpoint:
![Breakpoint](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Debugging+Setup+in+Docker/breakpoint.png)

2. Select *Start listening* ![Start listening](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Debugging+Setup+in+Docker/start-listening.png).
3. Open the application in a browser.
4. Navigate to the action you have configured the breakpoint for in step 1. The debugging process should be running in the IDE:
![Debug process](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Debugging+Setup+in+Docker/debug-process.png)


## How to switch to debugging mode: cookie, CLI or running in debug mode.

1. cookie - need to pass `XDEBUG_SESSION` cookie with any value. Or if  you use `Xdebug helper` extension in your browser, you need to turn on `debug`
2. `-x` mode - way for using debug mode in all applications
3. cli - if you need to debug some console command, you need to run `cli -x`. This command run cli with debug mode

## Timeouts

Warning: browser can stop the connection.

To avoid Zed Request timeout, you need to adjust configuration with:
```php
$config[ZedRequestConstants::CLIENT_OPTIONS] = [
    'timeout' => 0,
];
```

[Link to the troubleshooting page](../09-troubleshooting.md)
