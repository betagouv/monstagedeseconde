#!/bin/bash

# Main setup script
# This script orchestrates the entire setup process

set -e

# Source environment variables
# shellcheck disable=SC1091
source "$TEMP_DIR/env_vars"

# Run individual setup scripts
"$TEMP_DIR/.config/devcontainer/debian/scripts/setup-proxy.sh"
"$TEMP_DIR/.config/devcontainer/debian/scripts/install-packages.sh"
"$TEMP_DIR/.config/devcontainer/debian/scripts/install-taskfile.sh"
"$TEMP_DIR/.config/devcontainer/debian/scripts/setup-user.sh" "$USERNAME"

echo "Init process completed successfully."
