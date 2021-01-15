This document is a draft. See [Docker SDK](https://documentation.spryker.com/docs/docker-sdk) for official documentation.

## Description
Read the description below and, in the *Structure* section, fill out the document by answering the questions directly.

> Audience:
>
> - Devops who use docker/sdk for production or staging environments.
>
> Outcome:
> - You know how to configure build pipeline using docker/sdk.

## Outline

1. The example of build pipeline. Figure.
2. How to configure pipeline per environment.
3. Example of different pipelines in deploy.yml
```yaml
pipeline: docker.ci.acceptance
```
4. Recommendations:
 - Separation build and deployment pipelines
 - Tagging images with commit hash
 - Auto-build on a commit.


## Structure

:::(Info)(Structure)
The structure below is just a reference. We encourage you to add subsections, change or swap the provided sections if needed.
:::

### What would be an example of a build pipeline with docker/sdk?

### How do I configure a pipeline per enivornment?

### How would different pipelines look in deploy.yml?

### What are the recommendations for setting up build pipelines with docker/sdk?
