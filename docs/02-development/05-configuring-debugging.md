> Audience:
>
> - Developers who debug using the Docker SDK.
>
> Outcome:
> - You know how to configure debugging.
> - You know how to debug web applications, API, and console commands.


This document describes how to configure debugging of Spryker in Docker.

[Xdebug](https://xdebug.org) is the default debugging tool for Spryker in Docker. To enable Xdebug, run the command:
```bash
docker/sdk {run|start|up} -x
``` 

## Configuring Xdebug in PhpStorm

This section describes the required configuration for Xdebug in PhpStorm.

### Configuring Xdebug

To configure Xdebug in PhpStorm:
1. Go to **Preferences** > **Languages & Frameworks** > **PHP** > **Debug**.

2. In the *Xdebug* section:

      1. Depending on your requirements, enter a **Debug port**.
      2. Select the **Can accept external connections** checkbox.
      3. Clear the **Force break at first line when no path mapping specified** and **Force break at first line when a script is outside the project** checkboxes.

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
       

## Switching to the debugging mode
There are several ways to switch to the debugging mode:

* To debug a web application, pass the `XDEBUG_SESSION` cookie with a string value. If you are using the Xdebug helper browser extension, in the extension menu, select **debug**.
* To run all applications in the debugging mode, run `docker/sdk {run|start|up} -x`.
* To debug a console command in cli, run `{command} -x`.




## Debugging with Xdebug

To debug an application:

1. Make a breakpoint:
![Breakpoint](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Debugging+Setup+in+Docker/breakpoint.png)

2. Select *Start listening* ![Start listening](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Debugging+Setup+in+Docker/start-listening.png).

3. Open the application in a browser.

4. Navigate to the action you have configured the breakpoint for in step 1. The debugging process should be running in the IDE:
![Debug process](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Debugging+Setup+in+Docker/debug-process.png)




## Avoiding timeouts

The default Zed Request timout is 60 seconds. Debugging requests often take more than 60 seconds to complete. In this case, a browser stops the connection. 

To avoid Zed Request timeouts, adjust your configuration as follows:
```php
$config[ZedRequestConstants::CLIENT_OPTIONS] = [
    'timeout' => 300,
];
```

300 seconds should suit most cases, but you can increase it or even make it unlimited by defining the value as `0`.

:::(Warning) (Unlimited timout)
If you set unlitmited timout, this affects all Zed Requests, not only debugging ones. 


**Related articles**
[Troubleshooting](../09-troubleshooting.md)
