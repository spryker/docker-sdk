# Choosing a Docker SDK version

This document describes why and how to select a particular version of the Docker SDK and use it in your project.


## Why should I use a particular version of the Docker SDK?

You should use a particular Docker SDK version for:
- Compatibility: project configuration is compatible with the selected Docker SDK version.
- Consistency: the same Docker SDK version is used in development, integration and deployment pipelines.
- Control: control when and how you switch the Docker SDK version of the project.
- Stability: avoid unexpected behavior in pipelines.

## Choosing a versioning approach

To choose a versioning approach, consider the following:
- What kind of project do you have? For example, Long-term, short-term, production, demo.
- What will you use the Docker SDK for? For example, for development, operations, CI/CD management.
- Do you need to customize the Docker SDK?

Depending on your project requirements, choose on of the versioning approaches:

| Versioning approach | Compatibility | Consistency | Control | Stability | Cases |
|---|---|---|---|---|---|
| Release | + | + | + | + | Live projects. |
| Hash | + | + | + | +/- | Contributing into the Docker SDK. |
| Branch | + | - | + | +/- | Contributing into the Docker SDK. |
| Major branch `spryker/docker-sdk:1.x` | + | - | - | - | Demo projects. Backward compatibility checks. |
| Master branch `spryker/docker-sdk:master` | - | - | - | - | Short-term demo projects. Quick start. |
| Fork of `spryker/docker-sdk` | + | + | + | +  | Customization of the Docker SDK. |

:::(Info) (Fork)
[Spryker Cloud](https://cloud.spryker.com/) does not support forks of `spryker/docker-sdk`.
:::

## Сonfiguring a project to use the chosen version of the Docker SDK

Depending on your project requirements, choose one of the following ways to configure a Docker SDK version:

* Git submodule:
  * To contribute into the Docker SDK.
  * To have a simple way to fetch a particular version of the Docker SDK.
  * To use hash as a versioning approach.
* Reference file:
  * To use a branch as a versioning approach.
  * When Git Submodlue is not supported.

### Configuring git submodule

To configure git submodule:

1. Create a git submodule:
```bash
git submodule add git@github.com:spryker/docker-sdk.git ./docker
```

2. Checkout the local clone of the repository to a specific hash, branch, or tag:
```bash
cd docker
git checkout my-branch
cd ..
```

3. Commit and push:
```bash
git add .gitmodules docker
git commit -m "Added docker submodule"
git push
```

Commit and push the git submodule again each time you want to start using new version of Docker SDK:
```bash
git add docker
git commit -m "Updated docker submodule"
git push
```

See [7.11 Git Tools - Submodules](https://www.git-scm.com/book/en/v2/Git-Tools-Submodules) and [git-submodule reference](https://git-scm.com/docs/git-submodule) for more information about git submodule.


#### Using git submodule to stick to the chosen version

To fetch a chosen version of the Docker SDK, init or update the Docker SDK submodule:
```bash
git submodule update --init --force docker
```



### Configuring a reference file

To configure a reference file:

1. Create `.git.docker` in the project root.

2. Depending on the chosen versioning approach, add one of the following to the file:

|Versioning approach | Example |
|---|---|
|Hash|dbdfac276ae80dbe6f7b66ec1cd05ef21372988a|
|Release|1.24.0|
|Branch name|my-branch|
|Major branch|1.x|



3. Commit and push:
```bash
git add .git.docker
git commit -m "Added .git.docker"
git push
```

Commit and push the reference file each time you want to start using new version of the Docker SDK:
```bash
git add .git.docker
git commit -m "Updated .git.docker"
git push
```

#### Using a reference file to stick to the chosen version

Do the following to fetch a chosen version of the Docker SDK:

  1. Clone the Docker SDK repository.
  2. Read the reference from the file.
  3. According to the reference, checkout the local clone of the repository to the hash, branch, or tag.

 Example of a pipeline to fetch the chosen version of the Docker SDK:
  ```bash
  git clone git@github.com:spryker/docker-sdk.git .docker
  cd docker
  git checkout "$(cat ../.git.docker | tr -d '\n\r')"
  cd ..
  ```
