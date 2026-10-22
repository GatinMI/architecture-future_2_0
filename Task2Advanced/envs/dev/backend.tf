# ключи доступа - читаются из переменных окружения AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
# (в GitLab - masked/protected CI/CD-переменные).
terraform {
  backend "s3" {
    bucket = "tf-state"
    key    = "dev.tfstate"
    region = "ru-central1"

    # Для S3-совместимых хранилищ (MinIO, YOS)
    force_path_style            = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}
