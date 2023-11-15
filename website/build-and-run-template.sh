#!/bin/bash
# @file build-and-run-template.sh
# @brief Serve the HTML template through a webserver running inside Docker.
#
# @description This script automates the process of creating a Docker
# image designed to serve HTML templates through a webserver and then
# starting a container based on that image. The webserver serves the
# HTML templates to clients and listens on port 5353 for incoming requests.
#
# | Image Name                       | Port | URL                   |
# | -------------------------------- | ---- | --------------------- |
# | ``local/ui-bundle-template:dev`` | 5353 | http://localhost:5353 |
#
# === Script Arguments
#
# The script does not accept any parameters.
#
# === Script Example
#
# [source, bash]
# ```
# ./build-and-run-template.sh
# ```


set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


readonly IMAGE_NAME="local/ui-bundle-template:dev"
readonly PORT=5353


# Download and include logging library
rm -rf /tmp/bash-lib
mkdir -p /tmp/bash-lib
curl -sL https://raw.githubusercontent.com/sebastian-sommerfeld-io/jarvis/main/src/main/modules/bash-script/assets/lib/log.sh --output /tmp/bash-lib/log.sh
source /tmp/bash-lib/log.sh


LOG_HEADER "Expose HTML template"
(
    cd ui/template || exit

    LOG_INFO "Build image"
    docker build -t "$IMAGE_NAME" .

    LOG_INFO "Start container"
    docker run --rm mwendler/figlet "$PORT"
    docker run --rm -it -p "$PORT:8000" "$IMAGE_NAME"
)
