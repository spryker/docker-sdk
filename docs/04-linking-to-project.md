> Audience:
>
> - Everybody who start to use docker/sdk for developing and production.
>
> Outcome:
> - You know possibilities on how to link your project to the specific docker/sdk version.

## Why should you link your project to a specific docker/sdk version?


- Compatibility: You ensure compatibility between the project configuration and the linked docker/sdk version.
- Consistency: You constrain developers, integration and deployment pipelines to use the same docker/sdk version.
- Control: You control when and how you switch the project to a new docker/sdk functionality.
- Stability: You stabilize pipelines and make sure unexpected behavior doesn't happen.

## 1. Choose the version you want to link to.

Making your choice you should consider the following:
- What kind of the project is? Long-term, short-term, production, demo, etc.
- Who will use docker/sdk with the project? Developers, Devops, pipelines, etc.
- Do you need to make changes in docker/sdk itself?
- What are the efforts to maintain the link?

| Link to | Compatibility | Consistency | Control | Stability | Cases |
|---|---|---|---|---|---|
| Release | + | + | + | + | Live projects. |
| Hash | + | + | + | +/- | Using git submodule. Contributing into docker/sdk. |
| Branch | + | - | + | +/- | Contributing into docker/sdk. |
| Major branch `spryker/docker-sdk:1.x` | + | - | - | - | Demo projects. Backward compatibility checks. |
| Master branch `spryker/docker-sdk:master` | - | - | - | - | Short-term demo projects. Quick start. |
| Fork of `spryker/docker-sdk` | + | + | + | +  | Customization of docker/sdk. |

:::(Info) (Fork)
Spryker Cloud does not support forks of `spryker/docker-sdk`.
:::

## 2. Choose the way how the project repository contains the link.

### Git Submodule

Use this approach when you want:
- To customize docker/sdk.
- A simple way to fetch a specific version of docker/sdk.
- A strict hash-to-hash link.


1. Create a submodule:
```bash
git submodule add git@github.com:spryker/docker-sdk.git ./docker
```

2. Checkout the local clone of the repository to a specific hash,branch, or tag:
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

4. Commit and push the submodule again each time you need to refer to a new version of docker/sdk:
```bash
git add docker
git commit -m "Updated docker submodule"
git push
```

See [7.11 Git Tools - Submodules](https://www.git-scm.com/book/en/v2/Git-Tools-Submodules) and [git-submodule reference](https://git-scm.com/docs/git-submodule) for more details.

5. Prepare a tool to fetch the linked docker/sdk version:
Run the following to init or update the docker/sdk submodule:
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


### File with the reference

Use this approach when:
- Git Submodule is not supported. As example: AWS CodePipeline.
- You want to link to the latest commit in a branch.

1. Create `.git.docker` in the project root.

2. Depending on what you are linking to, add to the file one of the following:
  * Tag: `1.24.0` or `1.x`
  * branch name: `my-branch`
  * hash: `dbdfac276ae80dbe6f7b66ec1cd05ef21372988a`


3. Commit and push:
```bash
git add .git.docker
git commit -m "Added .git.docker"
git push
```

4. Commit and push the submodule each time you need to refer to a different hash,branch, or tag of docker/sdk.
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
