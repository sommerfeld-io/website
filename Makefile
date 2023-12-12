# @file Makefile
# @brief Build the website from its source files and run the website within a Docker container.
#
# @description This Makefile streamlines the process of building the website from its
# source files and orchestrating its execution within a Docker container.
#
# == How to use this Makefile
#
# The default target, which is triggered when simply using ``make`` combines ``make build``
# and ``make run``.
#
# === ``make build``
#
# Automates the process of creating a Docker image that encapsulates the entire
# link:https://www.sommerfeld.io[sommerfeld-io website] within an Apache httpd web server. The
# website is built with Antora first. This target simplifies the setup and configuration required
# to run the website locally. The image is based on the official link:https://hub.docker.com/_/httpd[Apache httpd]
# image.
#
# Per default, Apache httpd runs as ``root`` user because only root processes can listen to ports
# below 1024. The default http port for web applications is 80. But this means the user inside the
# container is ``root`` which poses a potential security risk. And since the webserver is running
# inside a Docker container it is not important what port is used inside the container. So the http
# port is changed to 7888 and the user is switched to the already present user ``www-data``.
#
# Apache is trying to write a file into ``/usr/local/apache2/logs``, but the ``www-data`` user does
# not have permission to create files in this directory. So permissions to this directory are
# updated as well.
#
# | Image                 | Port | Protocol |
# | --------------------- | ---- | -------- |
# | ``local/website:dev`` | 7888 | http     |
#
# The image is intended for local testing purposes. For production use, take a look at the
# link:https://hub.docker.com/r/sommerfeldio/website[``sommerfeldio/website``] image on
# Dockerhub.
#
# === ``make run``
#
# Launches a Docker container based on the newly created image. The container is started in the
# foreground. The locally hosted website can be accessed via a web browser at http://localhost:7888.
#
# === ``make build-ui``
#
# Automates the process of building the Antora UI bundle. Use this target from a Github Actions
# workflow to build the UI bundle from a pipeline. This target does not start up a webserver to
# preview the UI bundle in a browser.
#
# === ``make preview-ui``
#
# Run a local preview of the documentation site using the UI bundle. The preview uses demo
# content from the ``preview-src`` folder for testing and development purposes. The UI bundle
# preview is available through http://localhost:5252. This target uses ``make build-ui``
# as a prerequisites.
#
# === ``make preview-template``
#
# Exposes the HTML template through a webserver on http://localhost:5353.
#
# === ``make clean``
#
# Remove the local Docker image
#
# === ``make all``
#
# This phony target triggers all build-related targets (``make build-ui`` and ``make build``)
#
# == Prerequisites
#
# This Makefile needs Node, NPM and Gulp installed. To avoid having to install all
# prerequisites on your host, open the project in the devcontainer from this repo. Python3
# is needed as well. The xref:AUTO-GENERATED:-devcontainer/Dockerfile.adoc[DevContainer]
# for this repository ships all these depencencies.


WEBSITE_DOCKER_IMAGE = "local/website:dev"
WEBSITE_PORT = 7888
TEMPLATE_PORT = 5353

.DEFAULT_GOAL := run
.PHONY: all clean test build run install build-ui preview-ui preview-template lint-makefile lint-yaml lint-folders lint-filenames

all: build-ui build

lint-makefile:
	docker run --rm --volume "$(shell pwd):/data" cytopia/checkmake:latest Makefile

lint-yaml:
	docker run --rm  $$(tty -s && echo "-it" || echo) --volume $(shell pwd):/data cytopia/yamllint:latest .

lint-folders:
	docker run --rm -i --volume "$(shell pwd):$(shell pwd)" --workdir "$(shell pwd)" sommerfeldio/folderslint:latest folderslint

lint-filenames:
	docker run --rm -i --volume "$(shell pwd):/data" --workdir "/data" lslintorg/ls-lint:1.11.2

test: lint-makefile lint-yaml lint-folders lint-filenames
	docker run --rm -i hadolint/hadolint:latest < Dockerfile

build: test
	@echo "[INFO] Build Docker image $(WEBSITE_DOCKER_IMAGE)"
	docker build --no-cache -t "$(WEBSITE_DOCKER_IMAGE)" .

run: build
	@echo "[INFO] Run Docker image"
	docker run --rm mwendler/figlet:latest "$(WEBSITE_PORT)"
	docker run --rm -p "$(WEBSITE_PORT):7888" "$(WEBSITE_DOCKER_IMAGE)"

install:
	@cd ui/material-admin-pro/ui-bundle || exit \
		&& yarn install

build-ui: install
	@cd ui/material-admin-pro/ui-bundle || exit \
		&& gulp bundle

preview-ui: build-ui
	@cd ui/material-admin-pro/ui-bundle || exit \
		&& gulp preview

preview-template:
	@cd ui/material-admin-pro/template/pages || exit \
		&& docker run --rm mwendler/figlet:latest $(TEMPLATE_PORT) \
		&& python3 -m http.server $(TEMPLATE_PORT)

clean:
	@echo "[INFO] Remove old versions of $(WEBSITE_DOCKER_IMAGE)"
	docker image rm "$(WEBSITE_DOCKER_IMAGE)"

	@echo "[INFO] Cleanup local filesystem"
	rm -rf ui/material-admin-pro/ui-bundle/build
	rm -rf ui/material-admin-pro/ui-bundle/node_modules
	rm -rf ui/material-admin-pro/ui-bundle/public
