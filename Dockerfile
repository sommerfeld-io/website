# @file Dockerfile
# @brief Build and run the website.
#
# @description This Dockerfile is designed to simplify and streamline the build process of the
# link:https://www.sommerfeld.io[www.sommerfeld.io] website by integrating and building its various
# components. The main purpose of this Dockerfile is to generate the documentation sites using
# link:https://www.antora.org[Antora].
#
# === Prerequisites
#
# This image has been developed and tested with Docker version 24.0.7 on top of Ubuntu 23.10.
#
# === About the tags and versions
#
# include::ROOT:partial$/docker-tag-strategy.adoc[]
#
# == How to use
#
# Use ``docker run --rm -p "7888:7888" sommerfeldio/website:rc`` to run the moist recent release
# candidate from DockerHub.
#
# The most effective method to construct and operate the website on a local machine is by using
# the xref:AUTO-GENERATED:Makefile.adoc[Makefile].
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
# IMPORTANT: Make sure to control the image builds and containers by using the
# xref:AUTO-GENERATED:Makefile.adoc[Makefile]. The
# ``make src/main/ui/material-admin-pro/ui-bundle/build/ui-bundle.zip`` is a mandatory
# prerequisite (which the Makefile ensures). Otherwise the build breaks due to a
# missing UI bundle.
#
# Once all pages are built, the ``run`` stage of the image initiates an HTTP server using the Docker
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


FROM node:21.7.1-alpine3.19 AS build-antora-site
LABEL maintainer="sebastian@sommerfeld.io"

RUN yarn global add @asciidoctor/core@~3.0.2 \
    && yarn global add asciidoctor-kroki@~0.18.1 \
    && yarn global add @antora/cli@3.1.7 \
    && yarn global add @antora/site-generator@3.1.7 \
    && yarn global add @antora/lunr-extension@~1.0.0-alpha.8

COPY src/main/ui/material-admin-pro/ui-bundle/build/ui-bundle.zip /antora-src/main/ui/material-admin-pro/ui-bundle.zip
COPY config /antora
WORKDIR /antora

RUN antora --version \
    && antora playbooks/docs.yml --stacktrace --clean --fetch \
    && antora playbooks/personal-projects.yml --stacktrace --clean --fetch

# sleep for a moment ... otherwise the search-index.js is not built correctly
RUN sleep 5


FROM httpd:2.4.58-alpine3.19 AS run
LABEL maintainer="sebastian@sommerfeld.io"

COPY config/httpd.conf /usr/local/apache2/conf/httpd.conf

ARG USER=www-data
RUN chown -hR "$USER:$USER" /usr/local/apache2 \
    && chmod g-w /usr/local/apache2/conf/httpd.conf \
    && chmod g-r /etc/shadow \
    && rm /usr/local/apache2/htdocs/index.html

COPY --from=build-antora-site /tmp/antora/sommerfeld-io/public /usr/local/apache2/htdocs/docs
COPY --from=build-antora-site /tmp/antora/personal-projects/public /usr/local/apache2/htdocs/docs-personal-projects

COPY src/main/static-pages /usr/local/apache2/htdocs

RUN cp /usr/local/apache2/htdocs/docs/robots.txt /usr/local/apache2/htdocs/robots.txt

USER "$USER"
