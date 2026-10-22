variable "instance_name" {
  description = "Имя ВМ, например vm-dev"
  type        = string
}

variable "zone" {
  description = "Зона доступности"
  type        = string
}

variable "subnet_cidr" {
  description = "Адресный диапазон подсети окружения"
  type        = string
}

variable "vcpu_count" {
  description = "Количество виртуальных ядер"
  type        = number
}

variable "memory_gb" {
  description = "Объём оперативной памяти, ГБ"
  type        = number
}

variable "data_disk_size_gb" {
  description = "Размер подключаемого диска, ГБ"
  type        = number
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ"
  type        = string
}

variable "platform_id" {
  description = "Платформа вычислений"
  type        = string
}

variable "core_fraction" {
  description = "Гарантированная доля vCPU, %"
  type        = number
}

variable "disk_type" {
  description = "Тип дисков: network-hdd / network-ssd"
  type        = string
}

variable "preemptible" {
  description = "Спот-инстанс (дешевле, но может быть остановлен облаком)"
  type        = bool
}
