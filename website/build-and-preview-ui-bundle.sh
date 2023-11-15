#!/bin/bash
# @file build-and-preview-ui-bundle.sh
# @brief Preview and build the Antora UI bundle used for www.sommerfeld.io.
#
# @description This script automates the process of building the Antora UI
# bundle, running a local preview of the documentation site, and using demo
# content from the ``preview-src`` folder for testing and development purposes.
#
# | Port | URL                   |
# | ---- | --------------------- |
# | 5252 | http://localhost:5252 |
#
# === Prerequisites
#
# This script needs Node, NPM and Gulp installed. To avoid having to install
# all prerequisites on your host, open the project in the devcontainer from
# this repo.
#
# === Script Arguments
#
# The script does not accept any parameters.
#
# === Script Example
#
# [source, bash]
# ```
# ./build-and-preview-ui-bundle.sh
# ```

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


# Download and include logging library
rm -rf /tmp/bash-lib
mkdir -p /tmp/bash-lib
curl -sL https://raw.githubusercontent.com/sebastian-sommerfeld-io/jarvis/main/src/main/modules/bash-script/assets/lib/log.sh --output /tmp/bash-lib/log.sh
source /tmp/bash-lib/log.sh


LOG_HEADER "Preview and build the UI bundle"
(
    cd ui/ui-bundle || exit

    LOG_INFO "Install dependencies"
    yarn install

    LOG_INFO "Copy fonts"
    cp node_modules/@fontsource/poppins/files/poppins-*.woff* src/font

    LOG_INFO "Build UI bundle"
    gulp bundle

    LOG_INFO "Run preview"
    gulp preview
)
