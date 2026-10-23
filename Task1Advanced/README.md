# Задание 1. Модульная инфраструктура для нескольких сред

Переиспользуемый Terraform-модуль для развёртывания виртуальной машины в Yandex Cloud
(ВМ + подключаемый диск) и три окружения - dev, stage, prod - которые используют
один и тот же модуль с разными `.tfvars`.

## Структура

```
Task1Advanced/
├── modules/
│   └── vm/
│       ├── main.tf        # ВМ + подключаемый диск + сетевой интерфейс
│       ├── variables.tf   # входные параметры модуля
│       └── outputs.tf     # выходы: id и адреса ВМ, id диска
└── envs/
    ├── dev/               # main.tf, variables.tf, versions.tf, dev.tfvars
    ├── stage/             # main.tf, variables.tf, versions.tf, stage.tfvars
    └── prod/              # main.tf, variables.tf, versions.tf, prod.tfvars
```

Сеть (VPC + подсеть) создаётся на уровне окружения, а модуль подключает ВМ к
переданной подсети через параметр `subnet_id`. Сети трёх окружений не пересекаются,
а сам модуль ни к одному окружению не привязан - его можно использовать и для
следующих сред.

## Что делает модуль `modules/vm`

* создаёт ВМ на платформе `standard-v2` (настраивается) с образом Ubuntu 22.04 LTS
  из публичного каталога и эфемерным публичным IP;
* создаёт загрузочный диск 10 ГБ вместе с ВМ;
* создаёт подключаемый (вторичный) диск заданного размера - данные на нём живут
  независимо от жизненного цикла машины;
* подключает SSH-ключ из параметра `ssh_public_key`.

Внутри модуля нет значений, специфичных для окружения: имя, зона, ресурсы, размер
диска, подсеть, ключ и параметры стоимости приходят через переменные.

## Параметры модуля

| Переменная            | Тип    | По умолчанию | Описание |
|-----------------------|--------|--------------|----------|
| `instance_name`       | string | -            | Имя ВМ (vm-dev / vm-stage / vm-prod) |
| `zone`                | string | -            | Зона доступности (ru-central1-a и т.д.) |
| `vcpu_count`          | number | -            | Количество виртуальных ядер |
| `memory_gb`           | number | -            | Объём оперативной памяти, ГБ |
| `data_disk_size_gb`   | number | -            | Размер подключаемого диска, ГБ |
| `subnet_id`           | string | -            | ID подсети, в которую подключается ВМ |
| `ssh_public_key`      | string | -            | Публичный SSH-ключ |
| `platform_id`         | string | standard-v2  | Платформа вычислений |
| `core_fraction`       | number | 100          | Гарантированная доля vCPU, % (20 - burstable, дешевле) |
| `disk_type`           | string | network-ssd  | Тип дисков (network-hdd дешевле) |
| `preemptible`         | bool   | false        | Спот-инстанс: заметно дешевле, но облако может остановить ВМ |

## Выходы модуля

| Выход           | Описание |
|-----------------|----------|
| `instance_id`   | ID виртуальной машины |
| `instance_name` | Имя виртуальной машины |
| `internal_ip`   | Внутренний IP-адрес ВМ |
| `public_ip`     | Публичный IP-адрес ВМ |
| `data_disk_id`  | ID подключаемого диска |

## Различия окружений

| Параметр | dev | stage | prod |
|----------|-----|-------|------|
| Имя ВМ | vm-dev | vm-stage | vm-prod |
| Зона | ru-central1-a | ru-central1-a | ru-central1-b |
| Подсеть | 10.10.1.0/24 | 10.10.2.0/24 | 10.10.3.0/24 |
| Ядра / RAM | 2 / 2 ГБ | 4 / 8 ГБ | 8 / 16 ГБ |
| Подключаемый диск | 20 ГБ | 50 ГБ | 100 ГБ |
| Доля vCPU | 20% (burstable) | 100% | 100% |
| Тип дисков | network-hdd | network-hdd | network-ssd |
| Спот-инстанс | да | нет | нет |

prod намеренно в другой зоне, чтобы сбой в одной зоне не выбивал обе среды.
Для dev выбраны самые дешёвые опции: burstable vCPU, HDD-диски и спот-машина.

## Как запустить

Нужны Terraform >= 1.3 и облако Yandex Cloud с каталогом, в котором есть права
на создание ресурсов Compute/VPC.

1. Экспортируйте доступы (переменные окружения, которые понимает провайдер):

```bash
export YC_TOKEN="<токен>"
export YC_CLOUD_ID="<id облака>"
export YC_FOLDER_ID="<id каталога>"
```

2. Замените публичный SSH-ключ в нужном `.tfvars` на свой
   (`ssh-keygen -t ed25519`). 

3. Разверните окружение:

```bash
cd envs/dev
terraform init
terraform apply -var-file=dev.tfvars

# аналогично для stage и prod:
# cd ../stage && terraform init && terraform apply -var-file=stage.tfvars
# cd ../prod  && terraform init && terraform apply -var-file=prod.tfvars
```

4. IP-адреса и id появятся сразу после apply, а также через `terraform output`.

Удалить окружение:

```bash
terraform destroy -var-file=dev.tfvars
```


