source "incus" "vm" {
  image           = var.base_image
  virtual_machine = true
  profile         = var.profiles
  output_image    = local.output_image
  reuse           = true

  publish_properties = {
    description = var.image_description
  }
}
