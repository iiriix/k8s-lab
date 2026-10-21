#!/usr/bin/env bash
# Enable kubectl/kubeadm/crictl completion and the exam-style `k` alias
# Requires: bash-completion (in var.packages), 20-kubernetes.sh
set -euxo pipefail

bashrc=/etc/bash.bashrc
marker='# iiriix/k8s-lab: bash completion'

test -f /usr/share/bash-completion/bash_completion

kubectl completion bash >/etc/bash_completion.d/kubectl
kubeadm completion bash >/etc/bash_completion.d/kubeadm
crictl completion bash >/etc/bash_completion.d/crictl
cat >/etc/bash_completion.d/kubectl-k <<'EOF'
alias k=kubectl
complete -o default -F __start_kubectl k
EOF
chmod 644 /etc/bash_completion.d/{kubectl,kubeadm,crictl,kubectl-k}

if ! grep -qxF "${marker}" "${bashrc}"; then
  cat >>"${bashrc}" <<EOF

${marker}
if ! shopt -oq posix && [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi
EOF
fi
