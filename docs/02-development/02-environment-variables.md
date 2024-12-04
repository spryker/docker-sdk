# Passing Vulnerable Secrets for Local Development

This document explains how to use a **.env** file for the local environment.

## Configuring .env

1. Navigate to the **root directory of your project** and create a file named **.env**.
2. Set up the necessary secrets for your environment.
3. Bootstrap the Docker SDK:
```bash
   docker/sdk boot {deploy file name}
```
4. Start the local project:
```bash
docker/sdk up
```

Once the project is running, all secrets from the .env file will be accessible to all Spryker applications, such as Backoffice, Yves, etc.

**Note:** Ensure that **.env** is added to **.gitignore** (if not already) to prevent committing vulnerable secrets to the repository.
