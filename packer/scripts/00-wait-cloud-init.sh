#!/usr/bin/env bash
# Wait for cloud-init to finish so apt isn't locked by unattended-upgrades.
set -euo pipefail

# Give the guest a moment to start cloud-init before polling it.
sleep 10

# Exit code 2 means cloud-init finished with recoverable errors; don't fail the build on that.
cloud-init status --wait || [ $? -eq 2 ]
