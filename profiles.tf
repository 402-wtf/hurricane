locals {
  # flatcar-stable -> stable channel
  channel = split("-", var.os_channel)[1]
}

// Flatcar Linux install profile (from release.flatcar-linux.net)
resource "matchbox_profile" "flatcar-install" {
  count = length(var.controllers) + length(var.workers)
  name  = format("%s-flatcar-install-%s", var.cluster_name, concat(var.controllers.*.name, var.workers.*.name)[count.index])

  # https://flatcar-linux.org/docs/latest/installing/bare-metal/booting-with-ipxe/#setting-up-the-boot-script
  kernel = "${var.download_protocol}://${local.channel}.release.flatcar-linux.net/${concat(var.controllers.*.arch, var.workers.*.arch)[count.index]}-usr/${var.os_version}/flatcar_production_pxe.vmlinuz"

  initrd = [
    "${var.download_protocol}://${local.channel}.release.flatcar-linux.net/${concat(var.controllers.*.arch, var.workers.*.arch)[count.index]}-usr/${var.os_version}/flatcar_production_pxe_image.cpio.gz",
  ]

  args = flatten([
    "initrd=flatcar_production_pxe_image.cpio.gz",
    "ignition.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "flatcar.first_boot=1",
    "console=tty0",
    "console=ttyS0",
    var.kernel_args,
  ])

  container_linux_config = concat(data.template_file.controller-configs.*.rendered, data.template_file.worker-configs.*.rendered)[count.index]
}

// Flatcar Linux Install profile (from matchbox /assets cache)
// Note: Admin must have downloaded os_version into matchbox assets/flatcar.
resource "matchbox_profile" "cached-flatcar-install" {
  count = length(var.controllers) + length(var.workers)
  name  = format("%s-cached-flatcar-linux-install-%s", var.cluster_name, concat(var.controllers.*.name, var.workers.*.name)[count.index])

  # https://flatcar-linux.org/docs/latest/installing/bare-metal/booting-with-ipxe/#setting-up-the-boot-script
  kernel = "/assets/flatcar/${concat(var.controllers.*.arch, var.workers.*.arch)[count.index]}/${var.os_version}/flatcar_production_pxe.vmlinuz"

  initrd = [
    "/assets/flatcar/${concat(var.controllers.*.arch, var.workers.*.arch)[count.index]}/${var.os_version}/flatcar_production_pxe_image.cpio.gz",
  ]

  args = flatten([
    "initrd=flatcar_production_pxe_image.cpio.gz",
    "ignition.config.url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "flatcar.first_boot=1",
    "console=tty0",
    "console=ttyS0",
    var.kernel_args,
  ])

  container_linux_config = concat(data.template_file.controller-configs.*.rendered, data.template_file.worker-configs.*.rendered)[count.index]
}

data "ct_config" "controller-ignitions" {
  count    = length(var.controllers)
  content  = data.template_file.controller-configs.*.rendered[count.index]
  strict   = true
  snippets = lookup(var.snippets, var.controllers.*.name[count.index], [])
}

data "template_file" "controller-configs" {
  count = length(var.controllers)

  template = file("${path.module}/cl/controller.yaml")

  vars = {
    domain_name            = var.controllers.*.domain[count.index]
    etcd_name              = var.controllers.*.name[count.index]
    etcd_initial_cluster   = join(",", formatlist("%s=https://%s:2380", var.controllers.*.name, var.controllers.*.domain))
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
  }
}

data "ct_config" "worker-ignitions" {
  count    = length(var.workers)
  content  = data.template_file.worker-configs.*.rendered[count.index]
  strict   = true
  snippets = lookup(var.snippets, var.workers.*.name[count.index], [])
}

data "template_file" "worker-configs" {
  count = length(var.workers)

  template = file("${path.module}/cl/worker.yaml")

  vars = {
    domain_name            = var.workers.*.domain[count.index]
    cluster_dns_service_ip = module.bootstrap.cluster_dns_service_ip
    cluster_domain_suffix  = var.cluster_domain_suffix
    ssh_authorized_key     = var.ssh_authorized_key
    node_labels            = join(",", lookup(var.worker_node_labels, var.workers.*.name[count.index], []))
    node_taints            = join(",", lookup(var.worker_node_taints, var.workers.*.name[count.index], []))
  }
}
