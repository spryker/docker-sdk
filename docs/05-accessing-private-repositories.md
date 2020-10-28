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
