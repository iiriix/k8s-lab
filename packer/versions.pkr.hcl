packer {
  required_version = ">= 1.10.0"

  required_plugins {
    incus = {
      source  = "github.com/bketelsen/incus"
      version = "~> 1.0"
    }
  }
}
