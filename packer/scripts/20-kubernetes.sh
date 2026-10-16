#!/usr/bin/env bash
# Add the pkgs.k8s.io apt repository and install the Kubernetes node tools.
# Requires: KUBERNETES_VERSION (e.g. v1.35)
set -euxo pipefail

keyring=/usr/share/keyrings/kubernetes-apt-keyring.gpg
repo="https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/"
tools=(kubelet kubeadm kubectl cri-tools)

curl -fsSL "${repo}Release.key" | gpg --dearmor --yes -o "${keyring}"
chmod 644 "${keyring}"

echo "deb [signed-by=${keyring}] ${repo} /" > /etc/apt/sources.list.d/kubernetes.list
chmod 644 /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get -y install "${tools[@]}"
apt-mark hold "${tools[@]}"
