resource "matchbox_group" "install" {
  count = length(var.controllers) + length(var.workers)

  name = format("install-%s", concat(var.controllers.*.name, var.workers.*.name)[count.index])

  # pick Matchbox profile (Flatcar upstream or Matchbox image cache)
  profile = var.use_cache ? matchbox_profile.cached-flatcar-install.*.name[count.index] : matchbox_profile.flatcar-install.*.name[count.index]

  selector = {
    mac = concat(var.controllers.*.mac, var.workers.*.mac)[count.index]
  }
}
