# @file Makefile
# @brief Build the website from its source files and run the website within a Docker container.
#
# @description This Makefile streamlines the process of building the website from its
# source files and orchestrating its execution within Docker containers.
#
# === Prerequisites
#
# This Makefile needs Node, NPM and Gulp installed. To avoid having to install all
# prerequisites on your host, open the project in the DevContainer from this repo. This project
# has been developed in VSCode and tested with Docker version 24.0.7 on top of Ubuntu 23.10.
# The xref:AUTO-GENERATED:-devcontainer/Dockerfile.adoc[DevContainer] for this repository ships
# all these depencencies.
#
# == How to use this Makefile
#
# The default target, which is triggered when simply using ``make`` installs all dependencies,
# builds the UI bundle and starts all Docker containers by invoking ``make run``.
#
# === ``make run``
#
# Start all Docker containers for local development. Installing and buindling dependencies
# are triggered automatically if needed. Take a look at xref:AUTO-GENERATED:docker-compose-yml.adoc[docker-compose.yml]
# for further information on the started Docker containers.
#
# === ``make src/main/ui/material-admin-pro/ui-bundle/build/ui-bundle.zip``
#
# Automates the process of building the Antora UI bundle. Use this target from a Github Actions
# workflow to build the UI bundle from a pipeline. Installing dependencies is triggered
# automatically if needed.
#
# === ``make clean``
#
# Remove local Docker images, dependencies and build artifacts.
#
# == See also
#
# * xref:AUTO-GENERATED:Dockerfile.adoc[Dockerfile]
# * xref:AUTO-GENERATED:src/main/ui/material-admin-pro/ui-bundle/Dockerfile.adoc[src/main/ui/material-admin-pro/ui-bundle/Dockerfile]
# * xref:AUTO-GENERATED:docker-compose-yml.adoc[docker-compose.yml]

SRC_DIR = src/main
TEST_DIR = src/test
TARGET_DIR = target
LOGS_DIR = $(TARGET_DIR)/logs

UI_SRC_DIR = $(SRC_DIR)/ui/material-admin-pro/ui-bundle
NODE_MODULES = $(UI_SRC_DIR)/node_modules
FONTS = $(UI_SRC_DIR)/src/font
UI_BUNDLE_ZIP = $(UI_SRC_DIR)/build/ui-bundle.zip

WEBSITE_LOGS = $(LOGS_DIR)/website
WEBSITE_LOGS_ACCESS = $(WEBSITE_LOGS)/access.log
WEBSITE_LOGS_ERROR = $(WEBSITE_LOGS)/error.log

.DEFAULT_GOAL := run
.PHONY: all clean build-ui run lint-makefile lint-yaml lint-folders lint-filenames validate-inspec test

all: build-ui clean

lint-makefile:
	docker run --rm --volume "$(shell pwd):/data" cytopia/checkmake:latest Makefile

lint-yaml:
	docker run --rm  $$(tty -s && echo "-it" || echo) --volume $(shell pwd):/data cytopia/yamllint:latest .

lint-folders:
	docker run --rm -i --volume "$(shell pwd):$(shell pwd)" --workdir "$(shell pwd)" sommerfeldio/folderslint:latest folderslint

lint-filenames:
	docker run --rm -i --volume "$(shell pwd):/data" --workdir "/data" lslintorg/ls-lint:1.11.2

validate-inspec:
	docker run --rm --volume ./$(TEST_DIR)/inspec:/inspec --workdir /inspec chef/inspec:5.22.36 check website --chef-license=accept-no-persist

test: lint-makefile lint-yaml lint-folders lint-filenames validate-inspec
	docker run --rm -i hadolint/hadolint:latest < Dockerfile

$(NODE_MODULES):
	@cd $(UI_SRC_DIR) || exit \
		&& yarn install

$(FONTS): $(NODE_MODULES)
	@cd $(UI_SRC_DIR) || exit \
		&& mkdir -p src/font \
		&& cp node_modules/@fontsource/roboto/files/roboto-*.woff* src/font \
		&& cp node_modules/@fontsource/roboto-mono/files/roboto-mono-*.woff* src/font \
		&& cp node_modules/@fontsource/material-icons/files/material-icons-*.woff* src/font \
		&& cp node_modules/@fontsource/material-icons-outlined/files/material-icons-*.woff* src/font \
		&& cp node_modules/@fontsource/material-icons-round/files/material-icons-*.woff* src/font \
		&& cp node_modules/@fontsource/material-icons-sharp/files/material-icons-*.woff* src/font \
		&& cp node_modules/@fontsource/material-icons-two-tone/files/material-icons-*.woff* src/font

$(UI_BUNDLE_ZIP): $(FONTS)
	@cd $(UI_SRC_DIR) || exit \
		&& gulp bundle

$(WEBSITE_LOGS_ACCESS):
	mkdir -p $(WEBSITE_LOGS)
	touch $(WEBSITE_LOGS_ACCESS)
	chmod g+w $(WEBSITE_LOGS_ACCESS)
	chmod o+w $(WEBSITE_LOGS_ACCESS)

$(WEBSITE_LOGS_ERROR):
	mkdir -p $(WEBSITE_LOGS)
	touch $(WEBSITE_LOGS_ERROR)
	chmod g+w $(WEBSITE_LOGS_ERROR)
	chmod o+w $(WEBSITE_LOGS_ERROR)

run: test $(UI_BUNDLE_ZIP) $(WEBSITE_LOGS_ACCESS) $(WEBSITE_LOGS_ERROR)
	docker compose build --no-cache
	docker compose up

clean:
	@echo "[INFO] Remove containers"
	docker compose down --rmi all --volumes --remove-orphans

	@echo "[INFO] Cleanup ui bundle files"
	rm -rf $(FONTS)
	rm -rf $(UI_BUNDLE_ZIP)
	rm -rf $(NODE_MODULES)
	rm -rf $(UI_SRC_DIR)/public

	@echo "[INFO] Remove yarn.lock"
	rm -f $(UI_SRC_DIR)/yarn.lock

	@echo "[INFO] Remove target"
	rm -rf $(TARGET_DIR)
