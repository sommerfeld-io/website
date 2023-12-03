# @file Makefile
# @brief Build the website from its source files and run the website within a Docker container.
#
# @description This Makefile streamlines the process of building the website from its
# source files and orchestrating its execution within a Docker container.
#
# == Build an run the website
#
# The ``build`` target automates the process of creating a Docker image thatencapsulates
# the entire link:https://www.sommerfeld.io[sommerfeld-io website] within an Apache httpd
# web server. The website is built with Antora first. This target simplifies the setup and
# configuration required to run the website locally. The image is based on the official
# link:https://hub.docker.com/_/httpd[Apache httpd] image.
#
# [source, bash]
# ```
# make build
# ```
#
# The ``run`` target launches a Docker container based on the newly created image. The container
# is started in the foreground. The locally hosted website can be accessed via a web browser at
# http://localhost:7888.
#
# [source, bash]
# ```
# make run
# ```
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
# | What                  | Port | Protocol |
# | --------------------- | ---- | -------- |
# | ``local/website:dev`` | 7888 | http     |
#
# The image is intended for local testing purposes. For production use, take a look at the
# link:https://hub.docker.com/r/sommerfeldio/website[``sommerfeldio/website``]  image on
# Dockerhub.
#
# == Remove the Docker image
#
# To remove the local Docker image, just use ``make remove-image``
#
# == HTML Template
#
# To expose the HTML template through a webserver, just use ``make template``. The HTML
# template is available through http://localhost:5353.
#
# == Build and preview UI Bundle
#
# The ``ui-bundle`` target automates the process of building the Antora UI
# bundle, running a local preview of the documentation site, and using demo
# content from the ``preview-src`` folder for testing and development purposes.
#
# [source, bash]
# ```
# make ui-bundle
# ```
#
# The UI bundle preview is available through http://localhost:5252.
#
# NOTE: To build the UI bundle from a Github Actions workflow, use  ``make ui-bundle-build``.
# This target does not start up a webserver to preview the UI bundle in a browser.
#
# This target needs Node, NPM and Gulp installed. To avoid having to install
# all prerequisites on your host, open the project in the devcontainer from
# this repo.


WEBSITE_DOCKER_IMAGE = "local/website:dev"
WEBSITE_PORT = 7888

TEMPLATE_PORT = 5353

.DEFAULT_GOAL := run
.PHONY: all remove-image build run template ui-buncle-build ui-bundle clean test

all: ui-bundle-build build

remove-image:
	@echo "[INFO] Remove old versions of $(WEBSITE_DOCKER_IMAGE)"
	docker image rm "$(WEBSITE_DOCKER_IMAGE)"

build:
	@echo "[INFO] Build Docker image $(WEBSITE_DOCKER_IMAGE)"
	docker build --no-cache -t "$(WEBSITE_DOCKER_IMAGE)" .

run: build
	@echo "[INFO] Run Docker image"
	docker run --rm mwendler/figlet:latest "$(WEBSITE_PORT)"
	docker run --rm -p "$(WEBSITE_PORT):7888" "$(WEBSITE_DOCKER_IMAGE)"

template:
	@cd website/ui/template/pages || exit \
		&& docker run --rm mwendler/figlet:latest $(TEMPLATE_PORT) \
		&& python3 -m http.server $(TEMPLATE_PORT)

ui-bundle-build:
	@cd website/ui/ui-bundle || exit \
		&& yarn install \
		&& cp node_modules/@fontsource/poppins/files/poppins-*.woff* src/font \
		&& gulp bundle

ui-bundle: ui-bundle-build
	@cd website/ui/ui-bundle || exit \
		&& gulp preview

test:
	@echo "[INFO] Testing is done during the build targets"

clean:
	@echo "[INFO] Nothing to clean up"
