
instance_name     = "vm-stage"
zone              = "ru-central1-a"
subnet_cidr       = "10.10.2.0/24"
vcpu_count        = 4
memory_gb         = 8
data_disk_size_gb = 50
platform_id       = "standard-v2"
core_fraction     = 100
disk_type         = "network-hdd"
preemptible       = false

ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtGSH+jGI4jRM+yo4RKETIyHI1ir9SpN0BYyL78TdZj stage@example.local"
