# Конфигурация окружения dev: минимальная, для разработки.
# Держим на самых дешёвых опциях: burstable vCPU (20%), HDD-диски, спот-инстанс.

instance_name     = "vm-dev"
zone              = "ru-central1-a"
subnet_cidr       = "10.10.1.0/24"
vcpu_count        = 2
memory_gb         = 2
data_disk_size_gb = 20
platform_id       = "standard-v2"
core_fraction     = 20
disk_type         = "network-hdd"
preemptible       = true

# Замените на свой публичный ключ (ssh-keygen -t ed25519)
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIATPfLaofR8b3RPNGL73PrsATnLDY13XmYHp9WQ4kff+ dev@example.local"
