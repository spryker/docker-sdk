> Audience:
>
> - Devops who use docker/sdk for CI and CD.
> - Developers who use docker/sdk for development.
>
> Outcome:
> - You have a description of all components of the `Deploy file`.

# Outline

1. [Port the existing reference]
2. New section at the beginning: How to read this reference. Describes the order and reference format ('image: php: ini').
3. Extend the reference with the following features should be
- SC-3135: Release Docker-SDK
- SC-3116: Cache Busting Mechanism
- SC-3435: DD integration
- SC-3445: Provision of Developer Tooling
- SC-4606: Sender's email and name are defined in deploy.yml
- SC-4432: Mutagen as file synchronization alternative
- SC-4805: Xdebug can be excluded from images
- SC-4807: Define cors-allow-origin via deploy.yml
- SC-4434: SSH Agent is supported
4. Make each item as header to be able to have a link.
