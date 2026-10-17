#!/usr/bin/env bash
# Enable bash completion for all interactive shells, plus kubectl/kubeadm/crictl
# completion and the exam-style `k` alias.
# Requires: bash-completion (shipped by the base image), 20-kubernetes.sh
set -euxo pipefail

bashrc=/etc/bash.bashrc
marker='# iiriix/k8s-lab: bash completion'

test -f /usr/share/bash-completion/bash_completion

# Eagerly sourced, so __start_kubectl exists for the `k` alias below
kubectl completion bash >/etc/bash_completion.d/kubectl
kubeadm completion bash >/etc/bash_completion.d/kubeadm
crictl completion bash >/etc/bash_completion.d/crictl
chmod 644 /etc/bash_completion.d/{kubectl,kubeadm,crictl}

# Login shells get completion via /etc/profile.d; this covers non-login ones
# (e.g. `incus exec <vm> -- bash`). Appended rather than uncommenting Debian's
# block so it does not depend on the conffile's exact wording.
if ! grep -qxF "${marker}" "${bashrc}"; then
  cat >>"${bashrc}" <<EOF

${marker}
if ! shopt -oq posix && [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi
alias k=kubectl
complete -o default -F __start_kubectl k
EOF
fi
