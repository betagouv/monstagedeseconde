#!/bin/bash

# Perform Cleanup

set -e

# shellcheck disable=SC1091
source "$TEMP_DIR/env_vars"

cleanup() {
  echo "Performing cleanup..."

  sudo rm -rf "$TEMP_DIR"
  sudo apt-get clean
  sudo rm -rf /var/lib/apt/lists/*

  echo "Cleanup completed."
}

cleanup
