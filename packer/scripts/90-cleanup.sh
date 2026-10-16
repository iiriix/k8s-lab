#!/usr/bin/env bash
# Shrink the image and reset per-instance state so every clone starts fresh.
set -euxo pipefail

apt-get -y autoremove --purge
apt-get clean
rm -rf /var/lib/apt/lists/*

# Reset cloud-init and machine-id so each instance gets its own identity.
cloud-init clean --logs --machine-id

rm -f /var/log/wtmp /var/log/btmp
truncate -s0 /var/log/syslog /var/log/auth.log 2>/dev/null || true
journalctl --rotate && journalctl --vacuum-time=1s
