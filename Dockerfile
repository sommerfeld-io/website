# @file Dockerfile
# @brief Build and run the website.
#
# @description This Dockerfile is designed to simplify and streamline the build process of the
# link:https://www.sommerfeld.io[www.sommerfeld.io] website by integrating and building its various
# components. The main purpose of this Dockerfile is to generate the documentation sites using
# link:https://www.antora.org[Antora].
#
# Once all sites are built, the last stage of this multistage image starts an Apache server, making
# the website accessible over HTTP.
#
# == Prerequisites
#
# This image has been developed and tested with Docker version 24.0.2 on top of Ubuntu 22.10.
#
# == About the tags and versions
#
# include::ROOT:partial$/docker-tag-strategy.adoc[]
#
# === Example
#
# Use the xref:AUTO-GENERATED:build-and-run-website-sh.adoc[``build-and-run-website.sh``] script
# to build this image and start a container. The script basically invokes these two commands.
#
# [source, bash]
# ```
# docker build --no-cache -t local/website:dev .
# docker run --rm -p "7888:7888" local/website:dev
# ```
#
# == Image Structure
#
# This image is a multistage image, which means that the Dockerfile is structured to use multiple
# stages during the build process. The multistage build feature helps to create more efficient and
# smaller Docker images.
#
# The ``build-antora-site`` stage handles the construction of the Antora UI bundle, serving as the
# foundational component for building the actual website using Antora. Once the Antora UI bundle is
# built, it can serve as the foundation upon which the actual website content is added. Antora
# combines the content with the UI bundle to generate the final website, ensuring consistency in design
# and layout throughout the site.
#
# The Google font "Poppins" (https://www.npmjs.com/package/@expo-google-fonts/poppins?activeTab=readme)
# is now part of the ``package.json``. The Dockerfile takes care of copying the fonts from
# ``ui/ui-bundle/node_modules/@expo-google-fonts`` to ``ui/ui-bundle/src/font``.
#
# The ``build-ui-bundle`` stage leverages link:https://antora.org[Antora], a documentation site generator,
# to build the documentation sites of the website. Antora allows the documentation to be sourced from
# different repositories, making it easier to manage and update documentation across various projects.
# The configuration for Antora can be found in the ``config/playbooks`` folder. The contents from all
# repos are cloned from GitHub because (a) project files from the local machine filesystem (the docker-host)
# are not present inside container and (b) maybe not all relevant repositories are cloned on the local
# workstation, making it impossible to mount everything into the container.
#
# Once all the sites are built, the ``run`` stage of the image initiates an HTTP server using the Docker
# image link:https://hub.docker.com/_/httpd[httpd]. This HTTP server makes the entire website accessible
# over HTTP. The resulting image from this stage only includes the built files needed for serving the
# website, avoiding any unnecessary dependencies or intermediate build artifacts from previous stages.
# This approach helps to create a more efficient and smaller Docker image, which is advantageous for
# production deployment and distribution and reduces the surface for protential attacks.
#
# To avoid running the image as ``root``, the permissions of ``/usr/local/apache2/logs`` are changed to
# allow ``www-data`` to write logs. Additionally the default http port is changed to ``7888``, so keep
# that in mind when mapping ports in a ``docker run ...`` command. This way the image can be used without
# root permissions because the httpd server inside the container is started with the already existing
# user ``www-data``.
#
# The webserver exposes his status information through http://localhost:7888/server-status.
#
# == SBOM
#
# include::AUTO-GENERATED:partial$/sbom/sbom-website.adoc[]


FROM node:21-bullseye-slim AS build-ui-bundle
LABEL maintainer="sebastian@sommerfeld.io"

RUN yarn global add gulp-cli@2.3.0 \
    && yarn global add @antora/cli@3.1 \
    && yarn global add @antora/site-generator@3.1

COPY website/ui/ui-bundle /antora-ui
WORKDIR /antora-ui

RUN yarn install \
    && cp node_modules/@fontsource/poppins/files/poppins-*.woff* src/font \
    && gulp bundle


FROM antora/antora:3.1.5 AS build-antora-site
LABEL maintainer="sebastian@sommerfeld.io"

RUN yarn add @asciidoctor/core@~3.0.2 \
    && yarn add asciidoctor-kroki@~0.18.1 \
    && yarn add @antora/lunr-extension@~1.0.0-alpha.8

COPY --from=build-ui-bundle /antora-ui/build/ui-bundle.zip /antora-ui/ui-bundle.zip
COPY website/config /antora
WORKDIR /antora

RUN antora --version \
    && antora playbooks/docs.yml --stacktrace --clean --fetch \
    && antora playbooks/personal-projects.yml --stacktrace --clean --fetch

# sleep for a moment ... otherwise the search-index.js is not built correctly
RUN sleep 5


FROM httpd:2.4.58-alpine3.18 AS run
LABEL maintainer="sebastian@sommerfeld.io"

COPY website/config/httpd.conf /usr/local/apache2/conf/httpd.conf

ARG USER=www-data
RUN chown -hR "$USER:$USER" /usr/local/apache2 \
    && rm /usr/local/apache2/htdocs/index.html

COPY --from=build-antora-site /tmp/antora/sommerfeld-io/public /usr/local/apache2/htdocs/docs
COPY --from=build-antora-site /tmp/antora/personal-projects/public /usr/local/apache2/htdocs/docs-personal-projects

RUN cp /usr/local/apache2/htdocs/docs/robots.txt /usr/local/apache2/htdocs/robots.txt

USER "$USER"
