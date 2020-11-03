> Audience:
>
> - Everybody who start to use docker/sdk for developing and production.
>
> Outcome:
> - You know possibilities on how to link your project to the specific docker/sdk version.



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
- Do you need to make changes in docker/sdk?
- How much resources will you need to support docker/sdk in your project?


Depending on your project requirements, choose on of the version types:

| Version type | Compatibility | Consistency | Control | Stability | Cases |
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

## 2. How can I configure my project to use a particular version of docker/sdk?

Depending on your project requirements, choose one of the following ways to configure the link to docker/sdk:

* Git submodule:
  * To customize docker/sdk.
  * To have a simple way to fetch a particular version of docker/sdk.
  * To link hash to hash.
* Reference file:
  * To link to the latest commit in a branch.
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

4. Commit and push the git submodule again each time you need to refer to a new version of docker/sdk:
```bash
git add docker
git commit -m "Updated docker submodule"
git push
```

See [7.11 Git Tools - Submodules](https://www.git-scm.com/book/en/v2/Git-Tools-Submodules) and [git-submodule reference](https://git-scm.com/docs/git-submodule) for more details.

5. Prepare a tool to fetch the linked docker/sdk version:

  Init or update the docker/sdk submodule:
  ```bash
  git submodule update --init --force docker
  ```

 Example of a pipeline to fetch the proper version of docker/sdk:
  ```bash
  git clone git@github.com:spryker/docker-sdk.git .docker
  cd docker
  git checkout "$(cat ../.git.docker | tr -d '\n\r')"
  cd ..
  ```


### Reference file

To configure a reference file:

1. Create `.git.docker` in the project root.

2. Depending on what you are linking to, add one of the following to the file:
  * Tag. For example, `1.24.0` or `1.x`
  * Branch name. For example, `my-branch`
  * Hash. For example, `dbdfac276ae80dbe6f7b66ec1cd05ef21372988a`


3. Commit and push:
```bash
git add .git.docker
git commit -m "Added .git.docker"
git push
```

4. Commit and push the submodule each time you need to refer to a different hash, branch, or tag of docker/sdk.
```bash
git add .git.docker
git commit -m "Updated .git.docker"
git push
```

5. Prepare a tool to fetch the linked docker/sdk version:

  1. Clone the docker/sdk repository.
  2. Read the reference from the file.
  3. According to the reference, checkout the local clone of the repository to the hash, branch or tag.

 Example of a pipeline to fetch the proper version of docker/sdk:
  ```bash
  git clone git@github.com:spryker/docker-sdk.git .docker
  cd docker
  git checkout "$(cat ../.git.docker | tr -d '\n\r')"
  cd ..
  ```
