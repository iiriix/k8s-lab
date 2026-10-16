#!/usr/bin/env bash
# Add the Docker apt repository, install containerd and configure it for Kubernetes.
set -euxo pipefail

keyring=/usr/share/keyrings/docker.asc
# Docker publishes per-distro repos (debian, ubuntu, ...), so derive the URL from the base image.
# shellcheck source=/dev/null
. /etc/os-release
repo="https://download.docker.com/linux/${ID}"

curl -fsSL "${repo}/gpg" -o "${keyring}"
chmod 644 "${keyring}"

echo "deb [arch=$(dpkg --print-architecture) signed-by=${keyring}] ${repo} ${VERSION_CODENAME} stable" \
  > /etc/apt/sources.list.d/docker.list
chmod 644 /etc/apt/sources.list.d/docker.list

apt-get update
apt-get -y install containerd.io

# The packaged config disables the CRI plugin. Replace it with the full default
# config and switch runc to the systemd cgroup driver, which kubelet uses by default.
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
grep -q 'SystemdCgroup = true' /etc/containerd/config.toml

systemctl enable containerd
systemctl restart containerd
