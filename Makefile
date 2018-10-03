define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

CUR_DIR := $(abspath $(lastword $(MAKEFILE_LIST))/..)
APP_ROOT := $(CURDIR)
APP_NAME := thelper

# conda
CONDA_ENV ?= $(APP_NAME)
CONDA_HOME ?= $(HOME)/conda
CONDA_ENVS_DIR ?= $(CONDA_HOME)/envs
CONDA_ENV_PATH := $(CONDA_ENVS_DIR)/$(CONDA_ENV)
DOWNLOAD_CACHE := $(APP_ROOT)/downloads

# choose conda installer depending on your OS
CONDA_URL = https://repo.continuum.io/miniconda
OS_NAME := $(shell uname -s || echo "unknown")
ifeq "$(OS_NAME)" "Linux"
FN := Miniconda3-latest-Linux-x86_64.sh
else ifeq "$(OS_NAME)" "Darwin"
FN := Miniconda3-latest-MacOSX-x86_64.sh
else
FN := unknown
endif


.DEFAULT_GOAL := help

.PHONY: all
all: help

.PHONY: help
help:
	@echo "bump             bump version using version specified as user input"
	@echo "bump-dry         bump version using version specified as user input (dry-run)"
	@echo "bump-tag         bump version using version specified as user input, tags it and commits the change in git"
	@echo "clean            remove all build, test, coverage and Python artifacts"
	@echo "clean-build      remove build artifacts"
	@echo "clean-env        remove conda environment"
	@echo "clean-pyc        remove Python file artifacts"
	@echo "clean-test       remove test and coverage artifacts"
	@echo "lint             check style with flake8"
	@echo "test             run tests quickly with the default Python"
	@echo "test-all         run tests on every Python version with tox"
	@echo "coverage         check code coverage quickly with the default Python"
	@echo "docs             generate Sphinx HTML documentation, including API docs"
	@echo "install          install the package inside a conda environment"
	@echo "install-docs     install docs related components"

.PHONY: bump
bump: conda-env
	$(shell bash -c 'read -p "Version: " VERSION_PART; \
	source $(CONDA_HOME)/bin/activate $(CONDA_ENV); \
	$(CONDA_ENV_PATH)/bin/bumpversion --config-file $(CUR_DIR)/.bumpversion.cfg \
		--verbose --allow-dirty --no-tag --new-version $$VERSION_PART patch;')

.PHONY: bump-dry
bump-dry: conda-env
	$(shell bash -c 'read -p "Version: " VERSION_PART; \
	source $(CONDA_HOME)/bin/activate $(CONDA_ENV); \
	$(CONDA_ENV_PATH)/bin/bumpversion --config-file $(CUR_DIR)/.bumpversion.cfg \
		--verbose --allow-dirty --dry-run --tag --tag-name "{new_version}" --new-version $$VERSION_PART patch;')

.PHONY: bump-tag
bump-tag: conda-env
	$(shell bash -c 'read -p "Version: " VERSION_PART; \
	source $(CONDA_HOME)/bin/activate $(CONDA_ENV); \
	$(CONDA_ENV_PATH)/bin/bumpversion --config-file $(CUR_DIR)/.bumpversion.cfg \
		--verbose --allow-dirty --tag --tag-name "{new_version}" --new-version $$VERSION_PART patch;')

.PHONY: clean
clean: clean-build clean-pyc clean-test

.PHONY: clean-build
clean-build:
	@rm -fr $(CUR_DIR)/build/
	@rm -fr $(CUR_DIR)/dist/
	@rm -fr $(CUR_DIR)/.eggs/
	@find . -type f -name '*.egg-info' -exec rm -fr {} +
	@find . -type f -name '*.egg' -exec rm -f {} +

.PHONY: clean-env
clean-env:
	@-test -d $(CONDA_ENV_PATH) && "$(CONDA_HOME)/bin/conda" remove -n $(CONDA_ENV) --yes --all

.PHONY: clean-pyc
clean-pyc:
	@find . -type f -name '*.pyc' -exec rm -f {} +
	@find . -type f -name '*.pyo' -exec rm -f {} +
	@find . -type f -name '*~' -exec rm -f {} +
	@find . -type f -name '__pycache__' -exec rm -fr {} +

.PHONY: clean-test
clean-test:
	@rm -fr $(CUR_DIR)/.tox/
	@rm -f $(CUR_DIR)/.coverage
	@rm -fr $(CUR_DIR)/coverage/

.PHONY: lint
lint:
	@-bash -c "source $(CONDA_HOME)/bin/activate $(CONDA_ENV); \
	           test -f $(CONDA_ENV_PATH)/bin/flake8 || pip install flake8; \
	           flake8 src tests"

.PHONY: test
test:
	@bash -c "source $(CONDA_HOME)/bin/activate $(CONDA_ENV); python $(CUR_DIR)/setup.py test"

.PHONY: test-all
test-all:
	@bash -c "source $(CONDA_HOME)/bin/activate $(CONDA_ENV); tox"

.PHONY: coverage
coverage:
	@bash -c "source $(CONDA_HOME)/bin/activate $(CONDA_ENV); coverage run --source src/thelper setup.py test"
	@bash -c "source $(CONDA_HOME)/bin/activate $(CONDA_ENV); coverage report -m"
	@bash -c "source $(CONDA_HOME)/bin/activate $(CONDA_ENV); coverage html -d coverage"
	$(BROWSER) coverage/index.html

.PHONY: docs
docs: install-docs
	@bash -c "source $(CONDA_HOME)/bin/activate $(CONDA_ENV); \
		$(CUR_DIR)/docs/sphinx "apidoc" -o $(CUR_DIR)/docs/src $(CUR_DIR)/src; \
		$(MAKE) -C $(CUR_DIR)/docs clean; \
		$(MAKE) -C $(CUR_DIR)/docs html;"
	$(BROWSER) $(CUR_DIR)/docs/build/html/index.html

.PHONY: install-docs
install-docs: conda-env
	@-bash -c "source $(CONDA_HOME)/bin/activate $(CONDA_ENV); pip install -r $(CUR_DIR)/docs/src/requirements.txt"

.PHONY: install
install: conda-env
	@-bash -c "source $(CONDA_HOME)/bin/activate $(CONDA_ENV); pip install -e $(CUR_DIR) --no-deps"
	@echo "Framework successfully installed. To activate the conda environment, use:"
	@echo "    source $(CONDA_HOME)/bin/activate $(CONDA_ENV)"

.PHONY: conda-base
conda-base:
	@test -d $(CONDA_HOME) || test -d $(DOWNLOAD_CACHE) || mkdir $(DOWNLOAD_CACHE)
	@test -d $(CONDA_HOME) || test -f "$(DOWNLOAD_CACHE)/$(FN)" || curl $(CONDA_URL)/$(FN) --insecure --output "$(DOWNLOAD_CACHE)/$(FN)"
	@test -d $(CONDA_HOME) || (bash "$(DOWNLOAD_CACHE)/$(FN)" -b -p $(CONDA_HOME) && \
		echo "Make sure to add '$(CONDA_HOME)/bin' to your PATH variable in '~/.bashrc'.")

.PHONY: conda-cfg
conda_config: conda-base
	@echo "Updating conda configuration..."
	@"$(CONDA_HOME)/bin/conda" config --set ssl_verify true
	@"$(CONDA_HOME)/bin/conda" config --set use_pip true
	@"$(CONDA_HOME)/bin/conda" config --set channel_priority true
	@"$(CONDA_HOME)/bin/conda" config --set auto_update_conda false
	@"$(CONDA_HOME)/bin/conda" config --add channels defaults

# the conda-env target's dependency on conda-cfg above was removed, will add back later if needed

.PHONY: conda-env
conda-env: conda-base
	@test -d $(CONDA_ENV_PATH) || (echo "Creating conda environment at '$(CONDA_ENV_PATH)'..." && \
		"$(CONDA_HOME)/bin/conda" env create --file $(CUR_DIR)/conda-env.yml -n $(APP_NAME))