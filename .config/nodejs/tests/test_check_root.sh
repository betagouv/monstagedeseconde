#!/bin/bash

echo "Running test_check_root.sh..."

# Run the test as a non-root user
if ! sh install/debian.sh; then
  echo "✅ Test passed: Script correctly detected non-root execution."
else
  echo "❌ Test failed: Script did not detect non-root execution."
  exit 1
fi
