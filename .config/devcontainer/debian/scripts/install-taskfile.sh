#!/bin/bash

# Install Taskfile

set -e

# shellcheck disable=SC1091
source "$TEMP_DIR/env_vars"

install_taskfile() {
  echo "Installing Taskfile..."
  sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

  echo "Taskfile installation completed."
}

install_taskfile
