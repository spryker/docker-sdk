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

### Configuring Mutagen mount mode on MacOS

To configure Mutagen mount mode on MacOS:

1. Install or update [Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/install/) to the latest stable version.

2. Adjust the `mount:` section of `deploy.local.yml` as follows:
```yaml
docker:
...
    mount:
        mutagen:
            platforms:
                 - macos

```

3. Bootstrap docker/sdk:
```bash
docker/sdk boot
```

4. Follow the installation instructions displayed in the grey block of the output of the command you have run in the previous step.
 
5. Build and run Spryker application based on demo data:
```bash
docker/sdk up --build --data --assets
```

### Configuring docker-sync mount mode on MacOS

To configure docker-sync mount mode on MacOS:

1. Install ruby and ruby-dev 2.7.0preview1 or higher:
```bash
sudo apt-get install ruby ruby-dev
```

2. Install Unison 2.51.2 or higher:
```bash
brew install unison
```

3. Install docker-sync 0.5.11 or higher:
```bash
sudo gem install docker-sync
```

4. Adjust the mount section of `deploy.local.yml` as follows:
```yaml
docker:
...
   mount:
       docker-sync:
           platforms:
               - macos
```

5. Bootstrap docker/sdk:
```bash
docker/sdk boot
```

6. Follow the installation instructions displayed in the grey block of the output of the command you have run in the previous step.

7. Build and run Spryker application based on demo data:
```bash
docker/sdk up --build --data --assets
```

### Configuring native mount mode on Linux

To configure native mount mode on Linux:

1. Install or update Docker for Linux to the latest stable version.

2. Adjust the `mount:` section of `deploy.local.yml` as follows:
```yaml
docker:
...
   mount:
       native:
           platforms:
               - linux
```

3. Bootstrap docker/sdk:
```bash
docker/sdk boot
```

4. Follow the installation instructions displayed in the grey block of the output of the command you have run in the previous step.

5. Build and run Spryker application based on demo data:
```bash
docker/sdk up --build --data --assets
```

### Configuring docker-sync mount mode on Windows with WSL1

To configure docker-sync mount mode on Windows with Windows Subsystem for Linux 1 (WSL1):

1. Download and install Docker Desktop Stable 2.3.0.2 or higher. See [Install Docker Desktop on Windows](https://docs.docker.com/docker-for-windows/install/) to learn more.
2. Enable WSL1 by following [Windows Subsystem for Linux Installation Guide for Windows 10](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
3. In WSL, install the latest version of Docker:
    1. Update packages to the latest versions:
     ```bash
    sudo apt-get update
    ```
    2. Install the following packages to allow apt to access repositories via HTTPS:
    ```bash
    sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
    ```
    3. Add Docker's official GNU Privacy Guard key:
    ```bash
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    ```
    4. Set up a stable repository:
    ```bash
    sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
    ```
    5. Install the latest version of Docker Communitiy Edition:
    ```bash
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    ```
4. Install Docker Compose:
    1. Check the latest stable release of Docker Compose in [Docker Compose releases](https://github.com/docker/compose/releases).
    
    2. Download Docker Compose:
:::(Info) (Docker Compose version)
    Replace `{docker-compose-release}` in the command parameter with the version you have selected in the previous step.
    :::
    ```bash
    sudo curl -L "https://github.com/docker/compose/releases/download/{docker-compose-release}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    ```
    
    3. Apply executable permissions to the binary:
    ```bash
    sudo chmod +x /usr/local/bin/docker-compose
    ```
5. Install docker-sync:
    1. Install ruby and ruby-dev:
    ```bash
    sudo apt-get install ruby ruby-dev
    ```

    2. Install docker-sync:
    ```bash
    sudo gem install docker-sync
    ```
6. Set your Docker for Windows host as an environment variable:
    1. In Docker for Windows settings, check Expose daemon on `tcp://localhost:2375` without TLS.
    2. To update the profile with the environment variable, in your WSL shell, run the command:
    ```bash
    echo "export DOCKER_HOST=tcp://127.0.0.1:2375" >> ~/.bashrc
    ```
7. Compile and install OCaml:
    1. Install the build script:
    ```bash
    sudo apt-get install build-essential make
    ```
    2. Check the latest compatible OCaml version in [OCaml release changelog](https://github.com/ocaml/ocaml/releases). 
    In the next steps, replace `{ocaml-version}` in command parameters with the version you choose.
    3. Download the OCaml archive:
    ```bash
    wget http://caml.inria.fr/pub/distrib/ocaml-{ocaml-version}/ocaml-{ocaml-version}.tar.gz
    ```
    4. Extract the downloaded archive:
    ```bash
    tar xvf ocaml-{ocaml-version}.tar.gz
    ```
    5. Change the directory:
    ```bash
    cd ocaml-{ocaml-version}
    ```
    6. Configure and compile ocaml:
    ```bash
    ./configure
    make world
    make opt
    umask 022
    ```
    7. Install OCaml and clean:
    ```bash
    sudo make install
    sudo make clean
    ```
8. Compile and Install Unison:
    1. Check the latest version of Unison in [Unison releases](https://github.com/bcpierce00/unison/releases).
    In the next steps, replace `{unison-version}` in command parameters with the version you choose.
    2. Download the Unison archive:
    ```bash
    wget https://github.com/bcpierce00/unison/archive/{unison-version}.tar.gz
    ```
    3. Extract the archive:
    ```bash
    tar xvf {unison-version}.tar.gz
    ```
    4. Change the directory:
    ```bash
    cd unison-{unison-version}
    ```
    5. Compile and install Unison:
    ```bash
    make UISTYLE=text
    sudo cp src/unison /usr/local/bin/unison
    sudo cp src/unison-fsmonitor /usr/local/bin/unison-fsmonitor
    ```
9. Adjust the `mount:` section of `deploy.local.yml` as follows:
```yaml
docker:
...
   mount:
       docker-sync:
           platforms:
               - windows
```
10. Bootstrap docker/sdk:
```bash
docker/sdk boot
```
11. Follow the installation instructions displayed in the grey block of the output of the command you have run in the previous step.
12. Build and run Spryker application based on demo data:
```bash
docker/sdk up --build --data --assets
```

### How to configure native mount mode for Windows with WSL2

To configure native mount mode for Windows with WSL2:

1. Download and install Docker Desktop Stable 2.3.0.2 or a later release. See [Install Docker Desktop on Windows](https://docs.docker.com/docker-for-windows/install/) to learn more.
2. Enable Windows Subsystem for Linux 2 (WSL2) by following [Windows Subsystem for Linux Installation Guide for Windows 10](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
3. Install Docker in WSL:
    1. Update packages to the latest version:
     ```bash
     sudo apt-get update
     ```
    
    2. Install packages to allow apt to access repositories via HTTPS:
      ```bash
      sudo apt-get install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg-agent \
      software-properties-common
      ```
    
    3. Add Docker's official GNU Privacy Guard key:
      ```bash
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      ```
    
    4. Set up a stable repository:
      ```bash
      sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
      ```
    5. Install the latest version of Docker Community Edition:
      ```bash
      sudo apt-get install docker-ce docker-ce-cli containerd.io
      ```
    
    6. Install Docker Compose:
    1. Check the latest stable release of Docker Compose in [Docker Compose releases](https://github.com/docker/compose/releases).
    2. To download the version you have selected, replace `{docker-compose-release}` in the command parameter below and run it:
    ```bash
    sudo curl -L "https://github.com/docker/compose/releases/download/{docker-compose-release}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    ```
    3. Apply executable permissions to the binary:
    ```bash
    sudo chmod +x /usr/local/bin/docker-compose
    ```
4. Bootstrap docker/sdk.
```bash
docker/sdk boot
```
5. Follow the installation instructions displayed in the grey block of the output of the command you have run in the previous step.
6. Build and run Spryker application based on demo data.
```bash
docker/sdk up --build --data --assets
```
