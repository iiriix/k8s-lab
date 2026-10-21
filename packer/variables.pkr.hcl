variable "base_image" {
  type        = string
  description = "Incus image the template is built from"
  default     = "images:debian/trixie/cloud"
}

variable "image_name" {
  type        = string
  description = "Prefix of the published image alias; a build timestamp is appended"
  default     = "custom-debian-trixie"
}

variable "image_description" {
  type        = string
  description = "Description stored in the published image properties"
  default     = "Custom Debian Trixie (13) for labs"
}

variable "profiles" {
  type        = list(string)
  description = "Incus profiles applied to the build VM"
  default     = ["default"]
}

variable "packages" {
  type        = list(string)
  description = "Standard Debian packages to install on the image"
  default = [
    "apt-transport-https",
    "bash-completion",
    "ca-certificates",
    "curl",
    "etcd-client",
    "file",
    "gpg",
    "jq",
    "kubectx",
    "less",
    "podman",
    "ripgrep",
    "skopeo",
    "tree",
    "wget",
    "yq",
  ]
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes minor release used for the pkgs.k8s.io apt repository, e.g. v1.35"
  default     = "v1.35"

  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+$", var.kubernetes_version))
    error_message = "The kubernetes_version must look like \"v1.35\" (minor release, no patch)."
  }
}

variable "environment_vars" {
  type        = list(string)
  description = "Extra environment variables (KEY=VALUE) passed to every shell provisioner"
  default     = []
}
