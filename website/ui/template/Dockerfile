# @file Dockerfile
# @brief Serve the HTML templates, which are the foundation of the UI bundle, through a webserver.
#
# @description This Dockerfile is designed to create a Docker container that serves HTML templates,
# which are the foundation of the UI bundle, through a webserver.
#
# === Example
#
# Use the xref:AUTO-GENERATED:build-and-run-template-sh.adoc[``build-and-run-template.sh``]
# script to build this image and start a container.
#
# == Prerequisites
#
# This image has been developed and tested with Docker version 23.0.6 inside
# link:https://hub.docker.com/r/sommerfeldio/devcontainer-antora[``sommerfeldio/devcontainer-antora``].


FROM httpd:2.4.58-alpine3.18
LABEL maintainer="sebastian@sommerfeld.io"

ARG USER=www-data
RUN sed -i "/Listen 80/s/.*/Listen 8000/" /usr/local/apache2/conf/httpd.conf \
    && chown -hR "$USER:$USER" /usr/local/apache2

RUN rm /usr/local/apache2/htdocs/index.html

COPY pages /usr/local/apache2/htdocs

USER "$USER"
