#!/bin/bash

echo "Running test_full_install.sh..."

# Configuration de l'environnement de test
export NODEJS_MAJOR_VERSION=14
TEST_DIR=$(mktemp -d)
export HOME=$TEST_DIR

# Run the script with NODEJS_MAJOR_VERSION defined
if sudo NODEJS_MAJOR_VERSION=14 sh install/debian.sh 14; then
  echo "✅ Test passed: Full script ran successfully with NODEJS_MAJOR_VERSION set."
else
  echo "❌ Test failed: Full script did not run successfully."
  exit 1
fi

# Cleaning
rm -rf "$TEST_DIR"
