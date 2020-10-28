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
