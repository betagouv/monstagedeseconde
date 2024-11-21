#!/bin/bash

echo "Running test_check_nodejs_version.sh..."

# Run the test without defining NODEJS_MAJOR_VERSION
if ! sudo sh install/debian.sh; then
  echo "✅ Test passed: Script correctly detected missing NODEJS_MAJOR_VERSION."
else
  echo "❌ Test failed: Script did not detect missing NODEJS_MAJOR_VERSION."
  exit 1
fi

# Run the test with NODEJS_MAJOR_VERSION defined
if sudo sh install/debian.sh 14; then
  echo "✅ Test passed: Script accepted NODEJS_MAJOR_VERSION."
else
  echo "❌ Test failed: Script did not accept NODEJS_MAJOR_VERSION."
  exit 1
fi
