FROM cli-basic as cli
LABEL "spryker.image" "cli"

USER spryker:spryker

# Copying .git folders that was skipped in pipeline
RUN --mount=type=cache,id=vendor-dev,target=/vendor,uid=1000 \
  --mount=type=cache,id=rsync,target=/rsync,uid=1000 \
  LD_LIBRARY_PATH=/rsync /rsync/rsync -ap --chown=spryker:spryker /vendor/ ./vendor/ --include '.git*/' --exclude '*'

ARG SPRYKER_BUILD_HASH
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}
