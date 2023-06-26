#!/bin/bash
# @file build-and-run.sh
# @brief Build a Docker image containing the whole link:https://www.sommerfeld.io[www.sommerfeld.io]
# website and run locally inside a Docker container.
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
# === Script Arguments
#
# The script does not accept any parameters.


DOCKER_IMAGE="local/website:dev"
PORT=7888


echo -e "$LOG_INFO Remove old versions of $DOCKER_IMAGE"
docker image rm "$DOCKER_IMAGE"

echo -e "$LOG_INFO Build Docker image $DOCKER_IMAGE"
docker build --no-cache -t "$DOCKER_IMAGE" .

echo -e "$LOG_INFO Run Docker image"
docker run --rm mwendler/figlet "    $PORT"
docker run --rm -p "$PORT:80" "$DOCKER_IMAGE"
