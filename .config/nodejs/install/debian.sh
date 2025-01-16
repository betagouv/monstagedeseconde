#!/bin/sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print colored output
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
  echo "Usage: $0 [OPTIONS] NODEJS_MAJOR_VERSION"
  echo
  echo "Install or manage Node.js installation"
  echo
  echo "Options:"
  echo "  -h, --help        Display this help message"
  echo "  -u, --uninstall   Uninstall Node.js"
  echo "  -b, --backup      Backup existing Node.js configuration"
  echo
  echo "NODEJS_MAJOR_VERSION must be a positive integer (e.g., 14, 16, 18)"
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

# Function to backup existing Node.js configuration
backup_nodejs_config() {
  backup_dir="/tmp/nodejs_backup_$(date +%Y%m%d_%H%M%S)"
  print_color "$YELLOW" "Backing up existing Node.js configuration to $backup_dir..."

  mkdir -p "$backup_dir"

  # Backup global npm packages
  if command -v npm >/dev/null 2>&1; then
    npm list -g --depth=0 >"$backup_dir/global_packages.txt"
  fi

  # Backup npm configuration
  if [ -f ~/.npmrc ]; then
    cp ~/.npmrc "$backup_dir/npmrc_backup"
  fi

  print_color "$GREEN" "Backup completed."
}

# Function to uninstall Node.js
uninstall_nodejs() {
  print_color "$YELLOW" "Uninstalling Node.js..."

  sudo apt-get purge -y nodejs npm
  sudo rm -rf /etc/apt/sources.list.d/nodesource.list
  sudo rm -rf /usr/lib/node_modules
  sudo rm -rf ~/.npm

  print_color "$GREEN" "Node.js has been uninstalled."
  exit 0
}

# Check if the script is run by a user with sudo privileges
check_sudoers() {
  if [ "$(id -u)" -eq 0 ]; then
    print_color "$GREEN" "Script executed as root."
  elif sudo -n true 2>/dev/null; then
    print_color "$GREEN" "The user has sudo privileges."
  else
    error_exit "This script must be executed by a root user or with sudo privileges."
  fi
}

# Check if NODEJS_MAJOR_VERSION is provided and valid
check_nodejs_version() {
  if [ -z "$1" ]; then
    error_exit "NODEJS_MAJOR_VERSION is not defined or is empty."
  fi
  if ! echo "$1" | grep -q '^[0-9]\+$'; then
    error_exit "NODEJS_MAJOR_VERSION must be a positive integer."
  fi
  print_color "$GREEN" "Node.js version set to: $1"
}

# Function to configure npm to use proxy settings if they are set
configure_proxy() {
  proxy_value=$1
  npm_config_name=$2

  if [ -n "$proxy_value" ]; then
    print_color "$YELLOW" "Configuring $npm_config_name to use $proxy_value"
    sudo -E npm config set "$npm_config_name" "$proxy_value" || error_exit "Failed to set $npm_config_name"
  fi
}

# Function to add NodeSource GPG key
add_nodesource_gpg_key() {
  if [ ! -f /usr/share/keyrings/nodesource.gpg ]; then
    print_color "$YELLOW" "Adding NodeSource GPG key..."
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo -E gpg --dearmor -o /usr/share/keyrings/nodesource.gpg || error_exit "Failed to add NodeSource GPG key"
  else
    print_color "$YELLOW" "NodeSource GPG key already exists, skipping..."
  fi
}

# Function to add NodeSource APT repository
add_nodesource_apt_repo() {
  print_color "$YELLOW" "Adding NodeSource APT repository..."
  echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODEJS_MAJOR_VERSION.x $(lsb_release -cs) main" | sudo -E tee /etc/apt/sources.list.d/nodesource.list >/dev/null || error_exit "Failed to add NodeSource APT repository"
}

# Function to update package list
update_package_list() {
  print_color "$YELLOW" "Updating package list..."
  sudo -E apt-get update || error_exit "Failed to update package list"
}

# Function to install Node.js
install_nodejs() {
  print_color "$YELLOW" "Installing Node.js..."
  sudo -E apt-get install -y --no-install-recommends nodejs || error_exit "Failed to install Node.js"
}

# Function to update npm to the latest version
update_npm() {
  print_color "$YELLOW" "Updating npm to the latest version..."
  sudo -E npm install -g npm@latest || error_exit "Failed to update npm to the latest version"
}

# Function to display installed versions
display_versions() {
  print_color "$GREEN" "Installed versions:"
  node --version
  npm --version
}

# Main script execution
main() {
  check_sudoers

  if [ -f /etc/environment ]; then
    # shellcheck disable=SC1091
    . /etc/environment
  fi

  NODEJS_MAJOR_VERSION=""
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
      NODEJS_MAJOR_VERSION=$1
      shift
      ;;
    esac
  done

  if [ "$UNINSTALL" = true ]; then
    uninstall_nodejs
  fi

  if [ "$BACKUP" = true ]; then
    backup_nodejs_config
  fi

  check_nodejs_version "$NODEJS_MAJOR_VERSION"
  check_disk_space

  print_color "$YELLOW" "---------------------------"
  print_color "$YELLOW" "Installing Node.js version $NODEJS_MAJOR_VERSION"
  print_color "$YELLOW" "---------------------------"

  add_nodesource_gpg_key
  add_nodesource_apt_repo
  update_package_list
  install_nodejs

  configure_proxy "$HTTP_PROXY" "proxy"
  configure_proxy "$HTTPS_PROXY" "https-proxy"

  update_npm
  display_versions

  print_color "$GREEN" "✅ Node.js $NODEJS_MAJOR_VERSION and npm have been successfully installed and configured."
}

main "$@"
