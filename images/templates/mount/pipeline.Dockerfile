FROM pipeline-basic as pipeline-before-stamp
LABEL "spryker.image" "none"

USER spryker:spryker

FROM pipeline-before-stamp as pipeline
LABEL "spryker.image" "pipeline"

ARG SPRYKER_BUILD_HASH
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}
