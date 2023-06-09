#
# Stage 1: build
#
# Build Antora pages based on repositories from playbook.
# Contents are cloned from remote repoitories because project files from local
# machine filesystem (the docker-host) are not present inside container.
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

# sleep for a moment ... otherwise the search-index.js is not built correctly
RUN sleep 5

#
# Stage 2: run
#
# Run webserver with the Antora pages (built in previous stage).
#
# Permssions of /usr/local/apache2/logs are changed to allow accoss for www-data user
# and default http port is changed. See docs in ``build-and-run.sh`` for details.
#
FROM httpd:2.4.57-alpine3.18 AS run
LABEL maintainer="sebastian@sommerfeld.io"

ARG USER=www-data
RUN sed -i "/Listen 80/s/.*/Listen 7888/" /usr/local/apache2/conf/httpd.conf \
    && chown -hR "$USER:$USER" /usr/local/apache2

RUN rm /usr/local/apache2/htdocs/index.html
COPY --from=build /tmp/antora/website/public /usr/local/apache2/htdocs
COPY --from=build /tmp/antora/_personal-projects/public /usr/local/apache2/htdocs/_personal-projects

USER "$USER"
