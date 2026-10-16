locals {
  # Generates a timestamp string like "2026-10-14-2225"
  timestamp    = formatdate("YYYY-MM-DD-hhmm", timestamp())
  output_image = "${var.image_name}-${local.timestamp}"
  packages     = join(" ", var.packages)

  # Environment shared by every shell provisioner
  shell_env = concat([
    "DEBIAN_FRONTEND=noninteractive",
    "NEEDRESTART_MODE=a",
  ], var.environment_vars)
}
