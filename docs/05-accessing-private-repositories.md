This document is a draft. See [Docker SDK](https://documentation.spryker.com/docs/docker-sdk) for official documentation.

## Description
Read the description below and, in the *Structure* section, fill out the document by answering the questions directly.
We may have added some existing content and encourage you to update, remove or restructure it if needed.


> Audience:
>
> - Everybody who need access to private repositories when using docker/sdk for developing and production.
>
> Outcome:
> - You know how to configure environment to allow docker/sdk accessing your private repositories.

### When do I need to take care of private repositories?

1. I have a private repository mentioned in my composer.json:
```json
{
    "require": {
        "my-repo": "dev-master"
    },
    "repositories": [
        {
            "type": "git",
            "url": "git@github.com:my-org/my-repo.git"
        }
    ]
}
```

2. I get an error message running `docker/sdk up`:
```
Cloning into '/data/vendor/my-org/my-repo'...
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

### How to configure environment to allow access to private repositories?

1. Add a file `.known_hosts` into the project root with the list of domains of VCS services like in the example below.
```
github.com
bitbucket.org
gitlab.my-org.com
```

2. Choose an approach how Composer authenticates to VSC services.

| Approach | Development | CI pipelines | CD pipelines |
|---|---|---|---|
| SSH Agent | Recommended | + | + |
| COMPOSER_AUTH | + | Recommended | Recommended |

### Option 1. SSH agent

1. Make sure `GITHUB_TOKEN` or `COMPOSER_AUTH` environment variables are not set.
2. Prepare SSH agent by adding your private keys using `ssh-add` command.
3. Run `docker/sdk up --build`

```
unset GITHUB_TOKEN
unset COMPOSER_AUTH
eval $(ssh-agent)
ssh-add -K ~/.ssh/id_rsa
docker/sdk up --build
```

> Note for MacOS and Windows users: It may be necessary to restart your OS after adding keys into SSH agent for Docker Desktop to catch them up.

### Option 2. COMPOSER_AUTH environment variable

1. Create access tokens in your VSC services.
2. Prepare `COMPOSER_AUTH` environment variable in JSON format including tokens you've created.
Please, refer to the Composer official documentation: [COMPOSER_AUTH](https://getcomposer.org/doc/03-cli.md#composer-auth) and [Custom token authentication](https://getcomposer.org/doc/articles/authentication-for-private-packages.md#custom-token-authentication)

For GitHub:
```json
{
    "github-oauth": {
        "github.com": "token"
    }
}
```

For BitBucket:
```json
{
    "bitbucket-oauth": {
        "bitbucket.org": {
            "consumer-key": "key",
            "consumer-secret": "secret"
        }
    }
}
```

For GitLab
```json
{
    "gitlab-token": {
        "example.org": "token"
    }
}
```

3. Export `COMPOSER_AUTH` environment variable taking Bash escaping rules into in consideration.
4. Run `docker/sdk up --build`

```
export COMPOSER_AUTH="{\"github-oauth\":{\"github.com\":\"MY_GITHUB_TOKEN\"},\"gitlab-oauth\":{\"gitlab.com\":\"MY_GITLAB_PRIVATE_TOKEN\"},\"bitbucket-oauth\":{\"bitbucket.org\": {\"consumer-key\": \"MY_BITBUCKET_KEY\", \"consumer-secret\": \"MY_BITBUCLET_SECRET\"}}}"
docker/sdk up --build
```

> You can add `export COMPOSER_AUTH=...` into ~/.bash_profile or ~/.zshenv for your development environment.
