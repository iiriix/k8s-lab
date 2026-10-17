build {
  name = "incus-template"

  sources = ["source.incus.vm"]

  provisioner "shell" {
    script = "${path.root}/scripts/00-wait-cloud-init.sh"
  }

  # Kernel parameters and modules for Kubernetes
  provisioner "file" {
    source      = "${path.root}/files/99-kubernetes.conf"
    destination = "/etc/sysctl.d/99-kubernetes.conf"
  }

  provisioner "file" {
    source      = "${path.root}/files/k8s-modules.conf"
    destination = "/etc/modules-load.d/k8s.conf"
  }

  provisioner "shell" {
    environment_vars = concat(local.shell_env, [
      "PACKAGES=${local.packages}",
      "KUBERNETES_VERSION=${var.kubernetes_version}",
    ])
    scripts = [
      "${path.root}/scripts/10-base-packages.sh",
      "${path.root}/scripts/20-kubernetes.sh",
      "${path.root}/scripts/30-containerd.sh",
      "${path.root}/scripts/80-verify.sh",
      "${path.root}/scripts/90-cleanup.sh",
    ]
  }

  post-processor "shell-local" {
    inline = ["echo 'Built image: ${local.output_image}'"]
  }

}
