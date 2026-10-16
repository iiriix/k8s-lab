# k8s-lab

Personal lab for CKA/CKS practice. It provides ready-made
[Incus](https://linuxcontainers.org/incus/) machines with the Kubernetes
prerequisites already set up, so practice time goes into the exam tasks, not
node setup.

## Contents

- [`packer/`](packer/): builds a Debian VM image with containerd, kubeadm,
  kubelet and kubectl installed and the kernel already configured.
