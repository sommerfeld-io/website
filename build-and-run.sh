#!/bin/bash
# @file build-and-run.sh
# @brief Build Docker image containing the website and run locally inside a container.
#
# @description The script builds a Docker image containing the whole website inside an
# Apache httpd webserver and runs the image locally in a container. The base image is the
# link:https://hub.docker.com/_/httpd[official Apache httpd image].
#
# | What                  | Port | Protocol |
# | --------------------- | ---- | -------- |
# | ``local/website:dev`` | 7888 | http     |
#
# The image is intended for local testing purposes. Container is started in foreground.
#
# For production use, take a look at the image
# link:https://hub.docker.com/r/sommerfeldio/website[``sommerfeldio/website:latest``]
# on Dockerhub.
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
