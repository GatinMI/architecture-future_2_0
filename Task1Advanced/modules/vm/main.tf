terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

# Модуль развёртывает виртуальную машину в Yandex Cloud:
# ВМ + подключаемый (вторичный) диск + сетевой интерфейс в подсети,
# которую окружение передаёт параметром subnet_id.
# Внутри модуля нет значений, специфичных для окружения: всё приходит через переменные.

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_disk" "data" {
  name = "${var.instance_name}-data"
  zone = var.zone
  size = var.data_disk_size_gb
  type = var.disk_type
}

resource "yandex_compute_instance" "vm" {
  name                      = var.instance_name
  zone                      = var.zone
  platform_id               = var.platform_id
  allow_stopping_for_update = true

  boot_disk {
    device_name = "${var.instance_name}-boot"
    initialize_params {
      name     = "${var.instance_name}-boot"
      size     = 10
      type     = var.disk_type
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.data.id
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  resources {
    cores         = var.vcpu_count
    memory        = var.memory_gb
    core_fraction = var.core_fraction
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}