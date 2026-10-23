

variable "instance_name" {
  description = "Имя виртуальной машины, например vm-dev, vm-stage, vm-prod"
  type        = string
}

variable "zone" {
  description = "Зона доступности Yandex Cloud, например ru-central1-a"
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
  description = "Размер подключаемого (вторичного) диска, ГБ"
  type        = number
}

variable "subnet_id" {
  description = "ID подсети, к которой подключается ВМ"
  type        = string
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ для доступа к ВМ"
  type        = string
}

variable "platform_id" {
  description = "Платформа вычислений. standard-v2 - самая дешёвая"
  type        = string
  default     = "standard-v2"
}

variable "core_fraction" {
  description = "Гарантированная доля vCPU, %. 20 - burstable (дёшево), 100 - полная производительность"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Тип дисков. network-hdd - дёшево, network-ssd - быстро"
  type        = string
  default     = "network-ssd"
}

variable "preemptible" {
  description = "Предосведомляемая (спот) ВМ: примерно вдвое-втрое дешевле, но может быть остановлена облаком"
  type        = bool
  default     = false
}