
resource "yandex_vpc_network" "env" {
  name = "${var.instance_name}-net"
}

resource "yandex_vpc_subnet" "env" {
  name           = "${var.instance_name}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.env.id
  v4_cidr_blocks = [var.subnet_cidr]
}

module "vm" {
  source = "../../modules/vm"

  instance_name     = var.instance_name
  zone              = var.zone
  vcpu_count        = var.vcpu_count
  memory_gb         = var.memory_gb
  data_disk_size_gb = var.data_disk_size_gb
  subnet_id         = yandex_vpc_subnet.env.id
  ssh_public_key    = var.ssh_public_key

  platform_id   = var.platform_id
  core_fraction = var.core_fraction
  disk_type     = var.disk_type
  preemptible   = var.preemptible
}
