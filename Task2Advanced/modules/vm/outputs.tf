
output "instance_id" {
  description = "ID виртуальной машины"
  value       = yandex_compute_instance.vm.id
}

output "instance_name" {
  description = "Имя виртуальной машины"
  value       = yandex_compute_instance.vm.name
}

output "internal_ip" {
  description = "Внутренний IP-адрес ВМ"
  value       = yandex_compute_instance.vm.network_interface[0].ip_address
}

output "public_ip" {
  description = "Публичный IP-адрес ВМ"
  value       = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}

output "data_disk_id" {
  description = "ID подключаемого диска"
  value       = yandex_compute_disk.data.id
}
