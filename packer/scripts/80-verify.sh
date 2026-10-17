#!/usr/bin/env bash
# Sanity-check the kernel and runtime setup before the image is published.
set -euxo pipefail

/usr/lib/systemd/systemd-modules-load
lsmod | grep -q '^overlay'
lsmod | grep -q '^br_netfilter'
sysctl -p /etc/sysctl.d/99-kubernetes.conf

systemctl is-active --quiet containerd
crictl --runtime-endpoint unix:///run/containerd/containerd.sock info > /dev/null
kubeadm version -o short

# Non-login interactive shell, as `incus exec <vm> -- bash` would start
bash -ic 'type -t __start_kubectl && complete -p k' < /dev/null
