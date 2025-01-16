#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print coloured output
print_color() {
  printf "%b%s%b\n" "$1" "$2" "$NC"
}

# Function to print error messages and exit
error_exit() {
  print_color "$RED" "Error: $1" >&2
  exit 1
}

# Function to display help
display_help() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Install or manage Docker installation"
  echo
  echo "Options:"
  echo "  -h, --help        Display this help message"
  echo "  -u, --uninstall   Uninstall Docker"
  echo "  -b, --backup      Backup existing Docker configuration"
  exit 0
}

# Function to check available disk space
check_disk_space() {
  required_space=500 # Required space in MB
  available_space=$(df -m / | awk 'NR==2 {print $4}')

  if [ "$available_space" -lt "$required_space" ]; then
    error_exit "Insufficient disk space. At least ${required_space}MB is required, but only ${available_space}MB is available."
  fi
  print_color "$GREEN" "Sufficient disk space available."
}

# Function to backup existing Docker configuration
backup_docker_config() {
  backup_dir="/tmp/docker_backup_$(date +%Y%m%d_%H%M%S)"
  print_color "$YELLOW" "Backing up existing Docker configuration to $backup_dir..."

  mkdir -p "$backup_dir"

  # Backup Docker daemon configuration
  if [ -f /etc/docker/daemon.json ]; then
    sudo -E cp /etc/docker/daemon.json "$backup_dir/daemon.json_backup"
  fi

  # Backup Docker service files
  if [ -d /etc/systemd/system/docker.service.d ]; then
    sudo -E cp -r /etc/systemd/system/docker.service.d "$backup_dir/docker.service.d_backup"
  fi

  print_color "$GREEN" "Backup completed."
}

# Function to uninstall Docker
uninstall_docker() {
  print_color "$YELLOW" "Uninstalling Docker..."

  sudo -E apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
  sudo -E rm -rf /var/lib/docker
  sudo -E rm -rf /etc/docker
  sudo -E rm -rf ~/.docker

  print_color "$GREEN" "Docker has been uninstalled."
  exit 0
}

# Check if the script is run by a user with sudo -E privileges
check_sudoers() {
  if [ "$(id -u)" -eq 0 ]; then
    print_color "$GREEN" "Script executed as root."
  elif sudo -E -n true 2>/dev/null; then
    print_color "$GREEN" "The user has sudo privileges."
  else
    error_exit "This script must be executed by a root user or with sudo privileges."
  fi
}

# Function to add or update proxy settings in /etc/environment
configure_system_proxy() {
  proxy_value=$1
  env_var=$2
  env_file="/etc/environment"

  if [ -n "$proxy_value" ]; then
    print_color "$YELLOW" "Configuring system to use $env_var=$proxy_value"

    # Check if the variable already exists in the file
    if grep -q "^$env_var=" "$env_file"; then
      # Update existing entry
      sudo -E sed -i "s|^$env_var=.*|$env_var=$proxy_value|" "$env_file"
    else
      # Add new entry
      echo "$env_var=$proxy_value" | sudo -E tee -a "$env_file" >/dev/null
    fi
  fi
}

# Function to configure Docker to use proxy settings if they are set
configure_proxy() {
  proxy_value=$1
  env_var=$2
  proxy_file="/etc/systemd/system/docker.service.d/http-proxy.conf"
  proxy_setting="Environment=\"$env_var=$proxy_value\""

  if [ -n "$proxy_value" ]; then
    print_color "$YELLOW" "Configuring Docker to use $env_var=$proxy_value"
    if [ ! -f "$proxy_file" ]; then
      sudo -E mkdir -p /etc/systemd/system/docker.service.d
      echo "[Service]" | sudo -E tee "$proxy_file" >/dev/null
    fi

    if ! grep -q "$proxy_setting" "$proxy_file"; then
      echo "$proxy_setting" | sudo -E tee -a "$proxy_file" >/dev/null
    fi

    # Configure system-wide proxy
    configure_system_proxy "$proxy_value" "$env_var"
  fi
}

# Function to configure Docker client to use proxy settings
configure_docker_client_proxy() {
  docker_config_file="$HOME/.docker/config.json"

  print_color "$YELLOW" "Configuring Docker client proxy settings..."
  mkdir -p "$HOME/.docker"
  # shellcheck disable=SC2153
  cat <<EOF | tee "$docker_config_file" >/dev/null
{
  "log-driver": "json-file",
  "log-opts": {"max-size": "10m", "max-file": "3"},
  "proxies": {
    "default": {
      "httpProxy": "${HTTP_PROXY}",
      "httpsProxy": "${HTTPS_PROXY}",
      "ftpProxy": "${FTP_PROXY}",
      "noProxy": "${NO_PROXY}"
    }
  }
}
EOF
  print_color "$GREEN" "Docker client proxy settings configured."
}

# Function to add Docker GPG key and repository
add_docker_repo() {
  print_color "$YELLOW" "Adding Docker GPG key and repository..."

  if [ -f /etc/environment ]; then
    # shellcheck disable=SC1091
    . /etc/environment
  fi

  sudo -E apt-get update
  sudo -E apt-get install -y ca-certificates curl
  sudo -E install -m 0755 -d /etc/apt/keyrings

  if [ -n "$HTTP_PROXY" ]; then
    sudo -E curl --max-time 5 -fsSL --proxy "$HTTP_PROXY" https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc || error_exit "Failed to download Docker GPG key"
  else
    sudo -E curl --max-time 5 -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc || error_exit "Failed to download Docker GPG key"
  fi

  sudo -E chmod a+r /etc/apt/keyrings/docker.asc

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo -E tee /etc/apt/sources.list.d/docker.list >/dev/null || error_exit "Failed to add Docker APT repository"

  sudo -E apt-get update || error_exit "Failed to update package list"
  print_color "$GREEN" "Docker repository added successfully."
}

# Function to install Docker
install_docker() {
  print_color "$YELLOW" "Installing Docker..."

  if [ -f /etc/environment ]; then
    # shellcheck disable=SC1091
    . /etc/environment
  fi

  if ! dpkg -l | grep -q docker-ce; then
    sudo -E apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io docker-compose-plugin || error_exit "Failed to install Docker"
  else
    print_color "$GREEN" "Docker is already installed, skipping..."
  fi
}

# Function to install Docker buildx plugin
install_docker_buildx() {
  print_color "$YELLOW" "Installing Docker buildx plugin..."
  if ! dpkg -l | grep -q docker-buildx-plugin; then
    sudo -E apt-get install -y --no-install-recommends docker-buildx-plugin || error_exit "Failed to install Docker buildx plugin"
  else
    print_color "$GREEN" "Docker buildx plugin is already installed, skipping..."
  fi
}

# Main script execution
main() {
  UNINSTALL=false
  BACKUP=false

  # Parse command line options
  while [ $# -gt 0 ]; do
    case $1 in
    -h | --help)
      display_help
      ;;
    -u | --uninstall)
      UNINSTALL=true
      shift
      ;;
    -b | --backup)
      BACKUP=true
      shift
      ;;
    *)
      error_exit "Unknown option: $1"
      ;;
    esac
  done

  check_sudoers

  if [ -f /etc/environment ]; then
    # shellcheck disable=SC1091
    . /etc/environment
  fi

  if [ "$UNINSTALL" = true ]; then
    uninstall_docker
  fi

  if [ "$BACKUP" = true ]; then
    backup_docker_config
  fi

  check_disk_space

  configure_proxy "$HTTP_PROXY" "HTTP_PROXY"
  configure_proxy "$HTTPS_PROXY" "HTTPS_PROXY"
  configure_proxy "$NO_PROXY" "NO_PROXY"

  configure_docker_client_proxy

  print_color "$YELLOW" "---------------------------"
  print_color "$YELLOW" "Installing Docker"
  print_color "$YELLOW" "---------------------------"

  add_docker_repo
  install_docker
  install_docker_buildx

  if command -v systemctl >/dev/null 2>&1; then
    sudo -E systemctl daemon-reload
    sudo -E systemctl restart docker
  fi

  print_color "$GREEN" "✅ Docker has been successfully installed and configured."
}

main "$@"
