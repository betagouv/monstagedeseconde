#!/bin/bash

# Install Necessary Packages

set -e

# shellcheck disable=SC1091
source "$TEMP_DIR/env_vars"

install_packages() {
  echo "Updating package lists..."
  apt-get update

  echo "Installing necessary packages..."
  apt-get install -y --no-install-recommends \
    bash-completion \
    curl \
    git \
    gnupg2 \
    lsb-release \
    nano \
    openssh-client \
    python3-pip \
    python3-venv \
    sudo \
    unzip \
    wget

  echo "Package installation completed."
}

install_packages
