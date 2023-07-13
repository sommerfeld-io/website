#!/bin/bash
# @file build-and-run.sh
# @brief Build a Docker image containing the whole link:https://www.sommerfeld.io[www.sommerfeld.io] website and run locally inside a Docker container.
#
# @description The script automates the process of creating a Docker image that encapsulates
# the entire link:https://www.sommerfeld.io[sommerfeld-io website] within an Apache httpd web
# server and launches it as a container for local testing. The website is built with Antora first.
# This script simplifies the setup and configuration required to run the website locally. The
# image is based on the official link:https://hub.docker.com/_/httpd[Apache httpd] image.
#
# After the image is successfully built, the script launches a Docker container based on the
# newly created image. The container is started in the foreground. The locally hosted website
# can be accessed via a web browser at http://localhost:7888.
#
# | What                  | Port | Protocol |
# | --------------------- | ---- | -------- |
# | ``local/website:dev`` | 7888 | http     |
#
# The image is intended for local testing purposes. For production use, take a look at the
# link:https://hub.docker.com/r/sommerfeldio/website[``sommerfeldio/website``]  image on
# Dockerhub.
#
# === Use a UI bundle from your localhost
#
# To run this website configuration locally with a UI bundle from your localhost, make sure a
# ``ui-bundle.zip`` is available through a local webserver.
#
# For the link:https://github.com/sommerfeld-io/website-ui-bundle[``website-ui-bundle``] project,
# this can be done with the link:/website-ui-bundle/main/AUTO-GENERATED/bash-docs/src/main/ui-bundle-sh.html[``ui-bundle.sh``]
# script.
#
# To connect to the Docker host from within your container, pass the Docker host's IP address
# to the container using the ``--add-host`` flag. For this script this is needed to build the
# ``local/website:dev`` image. By leveraging this feature, the webserver running on the host
# is available  as ``docker-host-gateway`` (http://docker-host-gateway:5252/ui-bundle.zip)
# when building the image.
#
# Use inside your Antora playbook by referencing http://docker-host-gateway:5252/ui-bundle.zip
# as your UI bundle URL. 
#
# [source, yaml]
#
# ....
# ui:
#   bundle:
#     url: http://docker-host-gateway:5252/ui-bundle.zip
#     snapshot: true
# ....
#
# === Script Arguments
#
# The script does not accept any parameters.


DOCKER_HOST_GATEWAY="$(ip -4 addr show scope global dev docker0 | grep inet | awk '{print $2}' | cut -d / -f 1 | sed -n 1p)"
readonly DOCKER_HOST_GATEWAY
readonly DOCKER_IMAGE="local/website:dev"
readonly PORT=7888


echo -e "$LOG_INFO Remove old versions of $DOCKER_IMAGE"
docker image rm "$DOCKER_IMAGE"

echo -e "$LOG_INFO Build Docker image $DOCKER_IMAGE"
echo -e "$LOG_INFO DOCKER_HOST_GATEWAY = $DOCKER_HOST_GATEWAY"
docker build --no-cache --add-host="docker-host-gateway:$DOCKER_HOST_GATEWAY" -t "$DOCKER_IMAGE" .

echo -e "$LOG_INFO Run Docker image"
docker run --rm mwendler/figlet "$PORT"
docker run --rm -p "$PORT:7888" "$DOCKER_IMAGE"
