#!/usr/bin/env bash
# Wait for cloud-init to finish so apt isn't locked by unattended-upgrades.
# Base images without cloud-init (non-cloud variants) skip this step.
set -euo pipefail

if ! command -v cloud-init >/dev/null; then
  echo "cloud-init not installed in base image, skipping wait"
  exit 0
fi

# Give the guest a moment to start cloud-init before polling it.
sleep 10

# Exit code 2 means cloud-init finished with recoverable errors; don't fail the build on that.
cloud-init status --wait || [ $? -eq 2 ]
