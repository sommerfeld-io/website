# @file Dockerfile
# @brief Local development image which provides the preview for the UI bundle.
#
# @description This Dockerfile is used for local development purposes only. Despite being
# build and tested via a GitHub Actions workflow, it is never published to DockerHub. It
# remains confined to local usage. This particular Dockerfile is providing the preview for
# the UI bundle, enabling convenient development by running ``gulp preview``.
#
# === Prerequisites
#
# This image has been developed and tested with Docker version 24.0.7 on top of Ubuntu 23.10.
#
# == See also
#
# * xref:AUTO-GENERATED:Makefile.adoc[Makefile]
# * xref:AUTO-GENERATED:ui/material-admin-pro/ui-bundle/Dockerfile.adoc[ui/material-admin-pro/ui-bundle/Dockerfile]
# * xref:AUTO-GENERATED:docker-compose-yml.adoc[docker-compose.yml]


FROM node:21.4.0-bookworm-slim
LABEL maintainer="sebastian@sommerfeld.io"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir -p /ui-bundle \
    && yarn global add gulp-cli@2.3.0

WORKDIR /ui-bundle

ENTRYPOINT ["gulp"]
CMD ["preview"]
