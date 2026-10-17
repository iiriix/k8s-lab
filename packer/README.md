# Incus Kubernetes Node Template

Packer template that builds a Debian Trixie (13) Incus VM image ready to join a
kubeadm-based Kubernetes cluster.

## What's in the image

- Debian Trixie cloud image with all updates applied (`apt-get dist-upgrade`)
- Standard tooling: `curl`, `jq`, `yq`, `ripgrep`, `podman`, `skopeo`, `etcd-client`, `kubectx`, …
- `kubelet`, `kubeadm`, `kubectl` and `cri-tools` from `pkgs.k8s.io`, held at the chosen minor release
- `containerd` from the Docker apt repository, with the CRI plugin enabled and `SystemdCgroup = true`
- Kernel modules `overlay` and `br_netfilter` loaded at boot
- sysctl settings for Kubernetes networking (`ip_forward`, `bridge-nf-call-iptables`/`ip6tables`)
- cloud-init state and `machine-id` reset, so every instance gets its own identity

The published image is named `custom-debian-trixie-YYYY-MM-DD-hhmm`.

## Prerequisites

- [Packer](https://developer.hashicorp.com/packer/install) >= 1.10.0
- [Incus](https://linuxcontainers.org/incus/) with VM support, and access to the `images:` remote
- An Incus profile named `default` (or override `profiles`)

## Usage

Run from this directory:

```bash
packer init .
packer validate .
packer build .
```

Override variables on the command line:

```bash
packer build -var 'kubernetes_version=v1.34' -var 'profiles=["worker"]' .
```

or in a `*.auto.pkrvars.hcl` file, which Packer loads automatically:

```hcl
# local.auto.pkrvars.hcl
kubernetes_version = "v1.34"
profiles           = ["worker"]
```

Check the result:

```bash
incus image list custom-debian-trixie
incus launch <image-alias> k8s-node-1 --vm
```

### Custom cloud-init during the build

The build VM boots once with cloud-init, and whatever it does (for example
creating the distro's default `debian` user) ends up in the image;
`cloud-init clean` resets cloud-init's state but doesn't remove users.
To use your own cloud-init configuration instead:

- build from a cloud-init enabled base image (the default
  `images:debian/trixie/cloud` is one; non-`cloud` variants ignore user-data)
- pass an Incus profile that holds your `cloud-init.user-data` (starting with
  `#cloud-config`) and the VM's NIC and root disk devices, e.g. a copy of `default`:

  ```bash
  incus profile copy default packer-build
  incus profile set packer-build cloud-init.user-data "$(printf '#cloud-config\nusers: []\n')"
  packer build -var 'profiles=["packer-build"]' .
  ```

Everything that user-data does is baked into the image, so keep it to what
every instance should share. `users: []` builds an image with no default user.

## Variables

| Name                 | Default                      | Description                                                     |
|----------------------|------------------------------|-----------------------------------------------------------------|
| `base_image`         | `images:debian/trixie/cloud` | Incus image the template is built from                          |
| `image_name`         | `custom-debian-trixie`       | Prefix of the published image alias; a timestamp is appended    |
| `image_description`  | `Custom Debian Trixie (13) for labs` | Description stored in the published image properties    |
| `profiles`           | `["default"]`                | Incus profiles applied to the build VM                          |
| `packages`           | see `variables.pkr.hcl`      | Standard Debian packages to install                             |
| `kubernetes_version` | `v1.35`                      | Kubernetes minor release for the apt repo (must look like `v1.35`) |
| `environment_vars`   | `[]`                         | Extra `KEY=VALUE` env vars for every shell provisioner          |

`DEBIAN_FRONTEND=noninteractive` and `NEEDRESTART_MODE=a` are always set.

## Layout

```
.
├── versions.pkr.hcl    # Packer and plugin version constraints
├── variables.pkr.hcl   # Input variables
├── locals.pkr.hcl      # Derived values (timestamp, image name, shared env)
├── sources.pkr.hcl     # Incus source definition
├── build.pkr.hcl       # Provisioning steps, in order
├── files/              # Config files copied into the image
└── scripts/            # Provisioning scripts, run in numeric order
    ├── 00-wait-cloud-init.sh
    ├── ...
    └── 90-cleanup.sh
```

To add a provisioning step, drop a new numbered script into `scripts/` and add it
to the `scripts` list in `build.pkr.hcl`.
