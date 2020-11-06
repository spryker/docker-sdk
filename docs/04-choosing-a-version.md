> Audience:
>
> - Everybody who start to use docker/sdk for developing and production.
>
> Outcome:
> - You know possibilities on how to link your project to the specific docker/sdk version.
> - You know how to choose a docker/sdk versioning approach and link it to your project.





This document describes why and how to select a particular version of docker/sdk and use it in your project. 


## Why should you use a particular docker/sdk version?

You should link use a particular docker/sdk version for:
- Compatibility: project configuration is compatible with the selected docker/sdk version.
- Consistency: the same docker/sdk version is used in development, integration and deployment pipelines.
- Control: control when and how you switch the docker/sdk version of the project.
- Stability: avoid unexpected behavior in pipelines.

## How do you choose a docker/sdk version?

To choose a version, consider the following:
- What kind of project do you have? For example, Long-term, short-term, production, demo.
- What will you use docker/sdk for? For example, for development, operations, CI/CD management.
- Do you need to customize docker/sdk?

Depending on your project requirements, choose on of the versioning approaches:

| Versioning approach | Compatibility | Consistency | Control | Stability | Cases |
|---|---|---|---|---|---|
| Release | + | + | + | + | Live projects. |
| Hash | + | + | + | +/- | Contributing into docker/sdk. |
| Branch | + | - | + | +/- | Contributing into docker/sdk. |
| Major branch `spryker/docker-sdk:1.x` | + | - | - | - | Demo projects. Backward compatibility checks. |
| Master branch `spryker/docker-sdk:master` | - | - | - | - | Short-term demo projects. Quick start. |
| Fork of `spryker/docker-sdk` | + | + | + | +  | Customization of docker/sdk. |

:::(Info) (Fork)
Spryker Cloud does not support forks of `spryker/docker-sdk`.
:::

## 2. How do you configure a project to use a chosen version of docker/sdk?

Depending on your project requirements, choose one of the following ways to configure a chosen docker/sdk version:

* Git submodule:
  * To contribute into docker/sdk.
  * To have a simple way to fetch a particular version of docker/sdk.
  * To use hash as a versioning approach.
* Reference file:
  * To use a branch as a versioning approach.
  * When Git Submodlue is not supported.

### Git submodule 

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

Commit and push the git submodule again each time you want to start using new version of docker/sdk:
```bash
git add docker
git commit -m "Updated docker submodule"
git push
```

See [7.11 Git Tools - Submodules](https://www.git-scm.com/book/en/v2/Git-Tools-Submodules) and [git-submodule reference](https://git-scm.com/docs/git-submodule) for more information about git submodule.


#### How do you use git submodule to stick to the chosen version?

To fetch a chosen version of docker/sdk, init or update the docker/sdk submodule:
```bash
git submodule update --init --force docker
```



### Reference file

To configure a reference file:

1. Create `.git.docker` in the project root.

2. Depending on the chosen versioning approach, add one of the following to the file:

|Versioning approach | Example |
|---|---|
|Tag|1.24.0 or 1.x|
|Branch name|my-branch| 
|Hash|dbdfac276ae80dbe6f7b66ec1cd05ef21372988a| 



3. Commit and push:
```bash
git add .git.docker
git commit -m "Added .git.docker"
git push
```

Commit and push the reference file each time you want to start using new version of docker/sdk:
```bash
git add .git.docker
git commit -m "Updated .git.docker"
git push
```

#### How do you use a reference file to stick to the chosen version?

Do the following to fetch a chosen version of docker/sdk:

  1. Clone the docker/sdk repository.
  2. Read the reference from the file.
  3. According to the reference, checkout the local clone of the repository to the hash, branch, or tag.

 Example of a pipeline to fetch the chosen version of docker/sdk:
  ```bash
  git clone git@github.com:spryker/docker-sdk.git .docker
  cd docker
  git checkout "$(cat ../.git.docker | tr -d '\n\r')"
  cd ..
  ```
