This document is a draft. See [Docker SDK](https://documentation.spryker.com/docs/docker-sdk) for official documentation.

## Description
Read the description below and, in the *Structure* section, fill out the document by answering the questions directly.
We may have added some existing content and encourage you to update, remove or restructure it if needed. 


> Audience:
>
> - Everybody who need access to private repositories when using docker/sdk for developing and production.
>
> Outcome:
> - You know how to configure environment to allow docker/sdk access to your private repositories.

## Outline

1. Case when you need the instructions:
 - Module points to branch/release in private repo.
 - Symptoms: Error message
2. Step 1. Configure .known_hosts and commit.
3. Step 2. Option 1. How to use SSH agent and private keys.
 - When I should use SSH agent
4. Step 2. Option 2. How to use COMPOSER_AUTH?
 - When I should use token-based access?
 - GitHub
 - BitBucket
 - GitLab
