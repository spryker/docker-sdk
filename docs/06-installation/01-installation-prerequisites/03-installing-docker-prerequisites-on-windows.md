# Installing Docker prerequisites on Windows

This article describes Docker installation prerequisites for Windows.

@(Warning)()(When running commands described in this document, use absolute paths. For example: `mkdir /d/spryker && cd $_` or `mkdir /c/Users/spryker && cd $_`.)

## Minimum system requirements

Review the minimum system requirements in the table:

| System Requirement | Additional Details |
| --- | --- |
| Windows 10 64bit | Pro, Enterprise, or Education (1607 Anniversary Update, Build 14393 or later). |
| BIOS Virtualization is enabled | Typically, virtualization is enabled by default. Note that having the virtualization enabled is different from having Hyper-V enabled. This setting can be checked in the **Task Manager** > **Performance** tab.  For more details, see [Virtualization must be enabled](https://docs.docker.com/docker-for-windows/troubleshoot/#virtualization-must-be-enabled). |
| CPU SLAT-capable feature | SLAT is CPU related feature. It is called Rapid Virtualization Indexing (RVI). |
| RAM: 4GB | This is a minimum requirement. The value can be higher than 4GB. A lower value is not sufficient for installation purposes. |
| vCPU: 2 | This is a minimum requirement. The value can be higher than 2. A lower value is not sufficient for running the application. |

## Installing and configuring the required software with WSL2

Follow the steps below to install and configure the required software with WSL2:

1. [Enable WSL2 and install Docker Desktop](https://docs.docker.com/docker-for-windows/wsl/).

2. In the **General** tab of the Docker Desktop settings, select **Expose daemon on tcp://localhost:2375 without TLS**.

3. To save the settings, select **Apply & Restart**.

4. Install Ubuntu 20.04.

5. Run Ubuntu and update it:

```bash
sudo apt update && sudo apt dist-upgrade
```

6. Exit Ubuntu and restart Windows.


You've installed and configured the required software.

## Installing and configuring the required software with WSL1

:::(Error) (Outdated solution)
We highly recommend [installing and configuring the required software with WSL2](#installing-and-configuring-the-required-software-with-WSL2) since WSL1 is outdated, and you may get multiple issues with its configuration. Use it only if you can't use WSL2.
:::

Follow the steps below to install and configure the required software with WSL1.

### Install Docker Desktop    

Install Docker Desktop:

1. Download <a href="https://download.docker.com/win/stable/Docker for Windows Installer.exe">Docker Desktop for Windows</a>.

2. Open the installation file and follow the instructions of the wizard.

#### Enable Docker experimental features


Follow the steps to enable Docker experimental features:
1. Right-click the **Docker** icon in the tray and select **Settings**.
2. Select the **Daemon** tab.
3. Select the **Basic** checkbox.
4. Update variables as follows:

```json
    {
  ....
  "experimental": true,
  "features": {
    "buildkit": true
  }
}
```

### Enable WSL1

WSL is a Windows Subsystem for Linux. It allows Linux programs to run on Windows.

To enable WSL1:

1. Open **Windows Control Panel** > **Programs** > **Programs and Features**.
2. Select the **Turn Windows features on or off**  hyperlink.
![step 2](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Docker+Install+Prerequisites+-+Windows/w-features-on-off.png){height="" width=""}

3. Select **Windows Subsystem for Linux** and select **OK**.
![step 3](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Docker+Install+Prerequisites+-+Windows/windows-subsystem.png){height="" width=""}

### Install and update Ubuntu

Install Ubuntu:

1. Open Microsoft Store.
2. In the Search filed, enter *Ubuntu* and press *Enter*.
3. From the search results page, select **Ubuntu 18.04 LTS** and install it.
![Ubuntu step 3](https://spryker.s3.eu-central-1.amazonaws.com/docs/Developer+Guide/Installation/Spryker+in+Docker/Docker+Install+Prerequisites+-+Windows/ubuntu-in-store.png){height="" width=""}

Update Ubuntu:

1. Open the **Start menu**.
2. Find and launch **Ubuntu**.
3. Follow the instructions in the wizard.
4. Set the default root mount point in  `/etc/wsl.conf`.
```yaml
# Enable extra metadata options by default
[automount]
enabled = true
root = /
options = "metadata,umask=22,fmask=11"
mountFsTab = false
```
5. Restart Ubuntu.

### Install Docker

Install Docker:
1. Update the apt package:
```bash
sudo apt-get update
```

2. To allow `apt` to use a repository over HTTPS, install the packages:
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

5. Install the latest version of Docker CE:
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

### Install Docker Compose

Install Docker Compose:
1. Download the current stable release of Docker Compose:
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
2. Apply executable permissions to the binary:
```bash
sudo chmod +x /usr/local/bin/docker-compose
```

### Install docker-sync

Install docker-sync:

1. Install `ruby` and `ruby -dev`:
```bash
sudo apt-get install ruby ruby-dev
```
2. Install docker-sync:
```bash
sudo gem install docker-sync
```
3. Set your Docker for Windows host as an ENV variable:

    a. Open the **Docker for Windows** settings and select **Expose daemon on tcp://localhost:2375 without TLS**.
    b. Run the following command in your WSL shell:
```bash
echo "export DOCKER_HOST=tcp://127.0.0.1:2375" >> ~/.bashrc
```
### Install OCaml

Install OCaml:

1. Check [OCaml release changelog](https://github.com/ocaml/ocaml/releases) and make sure that the version you are going to install is compatible. In the procedure below, we are using version 4.06.0.

2. Install the build script:
```bash
sudo apt-get install build-essential make
```
3. Download the Ocaml archive:
```bash
wget http://caml.inria.fr/pub/distrib/ocaml-4.06/ocaml-4.06.0.tar.gz
```
4. Extract the downloaded archive:
```bash
tar xvf ocaml-4.06.0.tar.gz
```
5. Change the directory:
```bash
cd ocaml-4.06.0
```
6. Configure and compile Ocaml:
```bash
./configure
make world
make opt
umask 022
```
7. Install Ocaml and clean:
```bash
sudo make install
sudo make clean
```
## Install Unison

Follow the steps to install Unison:

1. Download the source code of the latest Unison version.
2. Compile and install it:
    1 . Download the Unison archive:
    ```bash
    wget https://github.com/bcpierce00/unison/archive/v2.51.2.tar.gz
    ```
    2. Extract the archive:

    ```bash
    tar xvf v2.51.2.tar.gz
    ```

    3. Change the directory:
    ```bash
    cd unison-2.51.2
    ```
    4. Compile and install Unison:
    ```bash
    $ make UISTYLE=text
    $ sudo cp src/unison /usr/local/bin/unison
    $ sudo cp src/unison-fsmonitor /usr/local/bin/unison-fsmonitor
    ```

You've installed and configured the required software.


## Next steps


See [Chossing an installation mode](../02-installation-guides/01-choosing-an-installation-mode.md) to choose an installation mode.
If you've already selected an installation mode, follow one of the guides below:
* [Installing in Development mode on Windows](../02-installation-guides/03-installing-in-development-mode-on-windows.md)
* [Installing in Demo mode on MacOS and Linux](../02-installation-guides/05-installing-in-demo-mode-on-windows.md)
* [Integrating the Docker SDK into existing projects](../02-installation-guides/06-integrating-the-docker-sdk-into-existing-projects.md)
* [Running production](../02-installation-guides/07-running-production.md)
