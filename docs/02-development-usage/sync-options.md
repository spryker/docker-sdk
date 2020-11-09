This document is a draft. See [Docker SDK](https://documentation.spryker.com/docs/docker-sdk) for official documentation.

## Description
Read the description below and, in the *Structure* section, fill out the document by answering the questions directly.

> Audience:
>
> - Developers who are developing with docker/sdk.
>
> Outcome:
> - You know how install and use source code synchronization tools based on the required platform.

## Outline
1. Short description how to set up necessary software for developing purpose.


:::(Warning)(Mutagen commands)
Docker SDK does not support native docker/mutagen commands. Use them at your own risk.
:::



### Mutagen - MacOS.

* Make sure you use Stable version of Docker Desktop for Mac (e.g. 2.3.0.4).
* Adjust deploy.local.yml mount section to the following:
```yaml
docker:
...
    mount:
        mutagen:
            platforms:
                 - macos

```
* Bootstrap docker/sdk.
```bash
docker/sdk boot
```
* Follow installation instructions displayed in the grey block during the execution of the previous command and execute `brew install mutagen-io/mutagen/mutagen-beta`.
*
```bash
docker/sdk up --build --data --assets
```


### Mutagen - Windows.


### Docker-Sync - MacOS.
1. Install Ruby and Ruby -dev. Make sure you use `Ruby` version `2.7.0preview1` or higher.
```bash
sudo apt-get install ruby ruby-dev
```
2. Install Unison. Make sure you use `Unison` version `2.51.2` or higher.
```bash
brew install unison
```
3. Install docker-sync. Make sure you use `Docker-sync` version `0.5.11` or higher.
```bash
sudo gem install docker-sync
```
4. Adjust deploy.local.yml mount section to the following:
```yaml
docker:
...
   mount:
       docker-sync:
           platforms:
               - macos
```
5. Bootstrap docker/sdk.
```bash
docker/sdk boot
```
6.
```bash
docker/sdk up --build --data --assets
```

### Docker-Sync - Windows.


