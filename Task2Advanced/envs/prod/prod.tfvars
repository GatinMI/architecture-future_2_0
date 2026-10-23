
instance_name     = "vm-prod"
zone              = "ru-central1-b"
subnet_cidr       = "10.10.3.0/24"
vcpu_count        = 8
memory_gb         = 16
data_disk_size_gb = 100
platform_id       = "standard-v2"
core_fraction     = 100
disk_type         = "network-ssd"
preemptible       = false

ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLnrK2XfdWTJI24W7ta845zO05T76mioyHLZiYXIWPh prod@example.local"
