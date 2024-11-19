#!/bin/bash

# Setup Proxy Configuration

set -e

# shellcheck disable=SC1091
source "$TEMP_DIR/env_vars"

configure_http_proxy() {
  if [ -n "$HTTP_PROXY" ]; then
    echo "Acquire::http::Proxy \"$HTTP_PROXY\";" >>"$proxy_file"
    echo "HTTP proxy configured."
  fi
}

configure_https_proxy() {
  if [ -n "$HTTPS_PROXY" ]; then
    echo "Acquire::https::Proxy \"$HTTPS_PROXY\";" >>"$proxy_file"
    echo "HTTPS proxy configured."
  fi
}

configure_ftp_proxy() {
  if [ -n "$FTP_PROXY" ]; then
    echo "Acquire::ftp::Proxy \"$FTP_PROXY\";" >>"$proxy_file"
    echo "FTP proxy configured."
  fi
}

configure_proxy() {
  local proxy_file="/etc/apt/apt.conf.d/95proxies"

  if [ -n "$HTTP_PROXY" ] || [ -n "$HTTPS_PROXY" ] || [ -n "$FTP_PROXY" ]; then
    echo "Configuring proxy settings..."
    : >"$proxy_file" # Clear the file
    configure_http_proxy
    configure_https_proxy
    configure_ftp_proxy
    echo "Proxy configuration completed."
  else
    echo "No proxy settings detected. Skipping proxy configuration."
  fi
}

configure_proxy
