#
# Stage 1: build
#
# Build Antora pages based on repositories from playbook.
# Contents are cloned from remote repoitories because project files from local
# machine (the docker-hosts) filesystem are not present inside container.
#
FROM antora/antora:3.1.2 AS build
LABEL maintainer="sebastian@sommerfeld.io"

RUN yarn global add @asciidoctor/core@~2.2 \
    && yarn global add asciidoctor-kroki

COPY config /antora

WORKDIR /antora

RUN antora --version \
    && antora generate playbooks/website.yml --stacktrace --clean --fetch \
    && antora generate playbooks/personal-projects.yml --stacktrace --clean --fetch

#
# Stage 2: run
#
# Run webserver with the Antora pages (built in previous stage).
#
FROM httpd:2.4-alpine AS run
LABEL maintainer="sebastian@sommerfeld.io"

RUN rm /usr/local/apache2/htdocs/index.html
COPY --from=build /tmp/antora/website/public /usr/local/apache2/htdocs
COPY --from=build /tmp/antora/personal-projects/public /usr/local/apache2/htdocs/personal-projects
