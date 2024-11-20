#!/bin/bash

# Setup Non-Root User

set -e

# shellcheck disable=SC1091
source "$TEMP_DIR/env_vars"

setup_user() {
  local USERNAME="$1"

  echo "Setting up non-root user: $USERNAME"
  useradd -m "$USERNAME"
  echo "$USERNAME ALL=(root) NOPASSWD:ALL" >"/etc/sudoers.d/$USERNAME"
  chmod 0440 "/etc/sudoers.d/$USERNAME"

  echo "Configuring shell for $USERNAME"
  echo 'source ~/.bashrc' >>"/home/$USERNAME/.bash_profile"
  echo "alias ll='ls -lisa --color'" >>"/home/$USERNAME/.bashrc"

  # Setup Taskfile completion
  wget --progress=dot:giga https://raw.githubusercontent.com/go-task/task/main/completion/bash/task.bash -O "/home/$USERNAME/task.bash"
  chmod +x "/home/$USERNAME/task.bash"
  echo 'source ~/task.bash' >>"/home/$USERNAME/.bashrc"

  echo "Non-root user setup completed."
}

setup_user "$1"
