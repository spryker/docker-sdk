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
1. Short description how to set up the environment for developing purpose.

### How to configure mutagen mount mode for MacOS platform.

* Make sure you use stable version of [Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/install/) (e.g. 2.3.0.4).
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
* Follow installation instructions displayed in the grey block during the execution of the previous command and execute:
 - `brew install mutagen-io/mutagen/mutagen-beta`
 - Adjust host file.
* Execute the following command to build and run Spryker application based on demo data:
```bash
docker/sdk up --build --data --assets
```

### How to configure docker-sync mount mode for MacOS platform.

* Install Ruby and Ruby -dev. Make sure you use `Ruby` version `2.7.0preview1` or higher:
```bash
sudo apt-get install ruby ruby-dev
```
* Install Unison. Make sure you use `Unison` version `2.51.2` or higher:
```bash
brew install unison
```
* Install docker-sync. Make sure you use `Docker-sync` version `0.5.11` or higher:
```bash
sudo gem install docker-sync
```
* Adjust deploy.local.yml mount section to the following:
```yaml
docker:
...
   mount:
       docker-sync:
           platforms:
               - macos
```
* Bootstrap docker/sdk:
```bash
docker/sdk boot
```
* Follow installation instructions displayed in the grey block during the execution of the previous command.
* Execute the following command to build and run Spryker application based on demo data:
```bash
docker/sdk up --build --data --assets
```

### How to configure native mount mode for Linux platform.

* Make sure you use stable version of Docker for Linux.
* Adjust deploy.local.yml mount section to the following:
```yaml
docker:
...
   mount:
       native:
           platforms:
               - linux
```
* Bootstrap docker/sdk:
```bash
docker/sdk boot
```
* Follow installation instructions displayed in the grey block during the execution of the previous command.
* Execute the following command to build and run Spryker application based on demo data:
```bash
docker/sdk up --build --data --assets
```

### How to configure docker-sync mount mode for Windows (WSL1) platform.
* Download [Docker Desktop Stable 2.3.0.2](https://docs.docker.com/docker-for-windows/install/), or a later release.
* Enable the WSL (Windows Subsystem for Linux). It allows Linux programs to run on Windows.
    * Open Windows *Control Panel* → *Programs* → *Programs and Features*.
    * Select *Turn Windows features on* or off *hyperlink*.
    * Check *Windows Subsystem for Linux* and click *OK*.
    * Install and Update Ubuntu.
        * Open Microsoft Store.
        * In the Search filed, enter "Ubuntu" and press Enter.
        * From the search results page, select Ubuntu 18.04 LTS and install it.
        * Once Ubuntu is installed, update it:
            * Open the *Start menu*.
            * Find and launch *Ubuntu*.
            * Follow the instructions in the wizard.
            * Set the default root mount point in */etc/wsl.conf*.
              ```yaml
              # Enable extra metadata options by default
              [automount]
              enabled = true
              root = /
              options = "metadata,umask=22,fmask=11"
              mountFsTab = false
              ```
        * Restart Ubuntu.
        * Install the latest version of Docker
            * Update distributive to the latest version.
             ```bash
             sudo apt-get update
             ```
            * Install packages to allow apt to use a repository over HTTPS:
              ```bash
              sudo apt-get install \
              apt-transport-https \
              ca-certificates \
              curl \
              gnupg-agent \
              software-properties-common
              ```
            * Add Docker's official GPG (GNU Privacy Guard) key:
              ```bash
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              ```
            * Set up a stable repository:
              ```bash
              sudo add-apt-repository \
              "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
              $(lsb_release -cs) \
              stable"
              ```
        * Install the latest version of Docker CE:
          ```bash
          sudo apt-get install docker-ce docker-ce-cli containerd.io
          ```
        * Install Docker Compose.
            * Download the current stable release of Docker Compose:
              ```bash
              sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              ```
            * Apply executable permissions to the binary:
              ```bash
              sudo chmod +x /usr/local/bin/docker-compose
              ```
        * Install Docker Sync.
            * Install Ruby and Ruby -dev:
              ```bash
              sudo apt-get install ruby ruby-dev
              ```
            * Install docker-sync:
              ```bash
              sudo gem install docker-sync
              ```
            * Set your Docker for Windows host as an ENV variable:
                * Open the *Docker for Windows* settings and check Expose daemon on *tcp://localhost:2375 without TLS*.
                * Run the following command in your WSL shell:
                  ```bash
                  echo "export DOCKER_HOST=tcp://127.0.0.1:2375" >> ~/.bashrc
                  ```
            * Compile and install OCaml.
              Before proceeding, check [OCaml release changelog](https://github.com/ocaml/ocaml/releases) and ensure that the OCaml version that you are going to install is compatible.
                * Install the build script:
                  ```bash
                  sudo apt-get install build-essential make
                  ```
                * Download the ocaml archive:
                  ```bash
                  wget http://caml.inria.fr/pub/distrib/ocaml-{latest-version}/ocaml-{latest-version}.tar.gz
                  ```
                * Extract the downloaded archive:
                  ```bash
                  tar xvf ocaml-{latest-version}.tar.gz
                  ```
                * Change the directory:
                  ```bash
                  cd ocaml-{latest-version}
                  ```
                * Configure and compile ocaml:
                  ```bash
                  ./configure
                  make world
                  make opt
                  umask 022
                  ```
                * Install ocaml and clean:
                  ```bash
                  sudo make install
                  sudo make clean
                  ```
                * Compile and Install Unison.
                    * Check [Unison release](https://github.com/bcpierce00/unison/releases).
                    * Download the Unison archive:
                      ```bash
                      wget https://github.com/bcpierce00/unison/archive/{latest-version}.tar.gz
                      ```
                    * Extract the archive:
                      ```bash
                      tar xvf {latest-version}.tar.gz
                      ```
                    * Change the directory:
                      ```bash
                      cd unison-{latest-version}
                      ```
                    * Compile and install Unison:
                      ```bash
                      make UISTYLE=text
                      sudo cp src/unison /usr/local/bin/unison
                      sudo cp src/unison-fsmonitor /usr/local/bin/unison-fsmonitor
                      ```
* Adjust deploy.local.yml mount section to the following:
```yaml
docker:
...
   mount:
       docker-sync:
           platforms:
               - windows
```
* Bootstrap docker/sdk.
```bash
docker/sdk boot
```
* Follow installation instructions displayed in the grey block during the execution of the previous command and execute them.
* Execute the following command to build and run Spryker application based on demo data.
```bash
docker/sdk up --build --data --assets
```

### How to configure native mount mode for Windows (WSL2) platform.

* Download [Docker Desktop Stable 2.3.0.2](https://docs.docker.com/docker-for-windows/install/), or a later release.
* Follow the [WLS2 installation guide](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
* When installation is finished proceed with docker installation guide:
    * Update distributive to the latest version.
     ```bash
     sudo apt-get update
     ```
    * Install packages to allow apt to use a repository over HTTPS:
      ```bash
      sudo apt-get install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common
      ```
    * Add Docker's official GPG (GNU Privacy Guard) key:
      ```bash
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      ```
    * Set up a stable repository:
      ```bash
      sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
      ```
    * Install the latest version of Docker CE:
      ```bash
      sudo apt-get install docker-ce docker-ce-cli containerd.io
      ```
    * Install Docker Compose.
      * Download the current stable release of Docker Compose:
        ```bash
        sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        ```
      * Apply executable permissions to the binary:
        ```bash
        sudo chmod +x /usr/local/bin/docker-compose
        ```
* Adjust deploy.local.yml mount section to the following:
```yaml
docker:
...
   mount:
       native:
           platforms:
               - windows
```
* Bootstrap docker/sdk.
```bash
docker/sdk boot
```
* Follow installation instructions displayed in the grey block during the execution of the previous command and execute them.
* Execute the following command to build and run Spryker application based on demo data.
```bash
docker/sdk up --build --data --assets
```
