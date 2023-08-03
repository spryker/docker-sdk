FROM frontend-basic as frontend-before-stamp
LABEL "spryker.image" "none"

FROM frontend-before-stamp as frontend
LABEL "spryker.image" "frontend"

ARG SPRYKER_BUILD_HASH
ENV SPRYKER_BUILD_HASH=${SPRYKER_BUILD_HASH}
ARG SPRYKER_BUILD_STAMP
ENV SPRYKER_BUILD_STAMP=${SPRYKER_BUILD_STAMP}

COPY --link <<-EOT /usr/share/nginx/build.json
{% include "images/templates/common/build.json" with _context %}
EOT
