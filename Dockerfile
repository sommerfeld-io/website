#
# Stage 1: build
#
# Build Antora pages based on repositories from playbook.
# Contents are cloned from remote repoitories because project files from local
# machine (the docker-hosts) filesystem are not present inside container.
#
FROM antora/antora:3.1.4 AS build
LABEL maintainer="sebastian@sommerfeld.io"

COPY config /antora

WORKDIR /antora

RUN yarn add @asciidoctor/core@~3.0.2 \
    && yarn add asciidoctor-kroki@~0.17.0 \
    && yarn add @antora/lunr-extension@~1.0.0-alpha.8

RUN antora --version \
    && antora playbooks/website.yml --stacktrace --clean --fetch \
    && antora playbooks/personal-projects.yml --stacktrace --clean --fetch

#
# Stage 2: run
#
# Run webserver with the Antora pages (built in previous stage).
#
FROM httpd:2.4-alpine AS run
LABEL maintainer="sebastian@sommerfeld.io"

RUN rm /usr/local/apache2/htdocs/index.html
COPY --from=build /tmp/antora/website/public /usr/local/apache2/htdocs
COPY --from=build /tmp/antora/_personal-projects/public /usr/local/apache2/htdocs/_personal-projects
