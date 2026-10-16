#!/usr/bin/env bash
# Upgrade the system and install the standard package set.
# Requires: PACKAGES (space-separated list)
set -euxo pipefail

apt-get update
apt-get -y -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef dist-upgrade
# shellcheck disable=SC2086 # word splitting is intended
apt-get -y install ${PACKAGES}
