# Задание 2. CI/CD-пайплайн GitLab + Terraform с удалённым state (S3/MinIO)

Инфраструктура Yandex Cloud (сеть + подсеть + ВМ с подключённым диском) для трёх
окружений dev/stage/prod управляется Terraform. Состояние хранится только в
S3-совместимом хранилище (локально - MinIO в docker compose, в контуре - MinIO
или Yandex Object Storage). Развёртывание автоматизировано пайплайном GitLab CI:
на каждый push в main автоматически прогоняются lint и plan, apply и destroy
запускаются только вручную (кнопка = approval).


## Backend: удалённое хранение state

`envs/<env>/backend.tf` (например, dev):

```hcl
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
```

Принципы:

* **У каждого окружения свой key** - `dev.tfstate` / `stage.tfstate` /
  `prod.tfstate`. State-файлы окружений не смешиваются, блокировки независимы.
* **В git - только публичные параметры** (имя бакета, key, флаги не-AWS
  хранилища). Секреты и адрес хранилища в репозиторий не попадают:
  * endpoint хранилища подставляется в CI флагом
    `terraform init -backend-config=endpoint="$TF_STATE_ENDPOINT"`
    (в GitLab - CI/CD-переменная проекта `TF_STATE_ENDPOINT`);
  * ключи доступа читаются terraform из переменных окружения
    `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (в GitLab - masked/protected
    CI/CD-переменные). Для MinIO это просто пара «пользователь/пароль»
    хранилища, для YOS - ключ доступа Yandex.
* **Локального state нет нигде**: `*.tfstate` и `.terraform/` в `.gitignore`,
  job-контейнер раннера эфемерный - после джобы файла state на диске не
  остаётся. Единственная копия state - в хранилище (MinIO/YOS/S3).
* Бакет создаётся до инициализации backend'а (в тесте - контейнером
  `minio-init` из compose; в контуре - вручную или отдельным скриптом).
  Terraform бакет не создаёт.

## CI-образ (Dockerfile)

```
docker build -t future20/terraform-yc:1.5.7 .
```

* База - официальный `hashicorp/terraform:1.5.7`.
* Провайдер `yandex-cloud/yandex` v0.239.0 скачивается из GitHub-релиза при
  сборке, sha256 пакета сверяется (`YANDEX_PROVIDER_SHA256`, сверить по
  релизу yandex-cloud/terraform-provider-yandex) и кладётся в неявный локальный
  mirror `/usr/local/share/terraform/plugins/...`. Поэтому `terraform init`
  в джобах работает офлайн - раннеру не нужен доступ к registry.terraform.io.
* `ENTRYPOINT []`: в официальном образе entrypoint - `terraform`, а раннер
  запускает скрипты джоб через `sh -c`, что с таким entrypoint ломается
  (`terraform sh ...`). Для CI-образа entrypoint сбрасывается, команды
  `terraform` в скриптах вызываются явно.
* Версия провайдера дополнительно зафиксирована закоммиченными
  `.terraform.lock.hcl` - воспроизводимая инициализация.

## Пайплайн (.gitlab-ci.yml)

Стадии: `lint -> plan -> apply -> destroy`, по комплекту джоб на каждое
окружение (dev/stage/prod). Пайплайн ходит только по основной ветке
(`workflow.rules`), ветка main защищена от пушей без процесса.

| Джоба | Тип | Что делает |
|---|---|---|
| `lint` | авто | `terraform fmt -check -recursive` - контроль формата |
| `plan:<env>` | авто | `init` (с удалённым backend) -> `validate` -> `plan -out=tfplan.<env> -var-file=<env>.tfvars`; plan-файл - артефакт (живёт 1 день) |
| `apply:<env>` | **ручной** (кнопка Play) | `init` -> `apply -auto-approve tfplan.<env>` - применяет ровно тот план, что был показан и сохранён артефактом план-джобой |
| `destroy:<env>` | **ручной** (кнопка Play) | `init` -> `destroy -auto-approve -var-file=<env>.tfvars` - снимает окружение по remote state |

Ключевые механизмы безопасности и изоляции:

* **Approval.** `apply` и `destroy` - `when: manual`: джоба не стартует без
  явного нажатия кнопки (в UI или через API `POST /jobs/:id/play`). Plan на
  каждый push идёт автоматически и не меняет ничего.
* **Точность apply.** apply применяет сохранённый plan-файл из артефакта
  (`needs: [job: plan:<env>]`), а не пересчитывает план заново - «показали и
  согласовали N изменений -> применились именно они».
* **Одновременный apply/destroy одного окружения исключён**: `resource_group:
  terraform-<env>` - вторая джоба того же окружения будет ждать.
* **destroy доступен сразу после plan** (`needs: [job: plan:<env>, artifacts:
  false]`): уборка не блокируется упавшим или отклонённым apply и не
  потребует план-артефактов (destroy читает удалённый state).
* **Секреты не в репозитории.** В `.gitlab-ci.yml` и во всём коде нет ни
  токенов, ни ключей, ни эндпоинтов - только имена переменных. Значения - в
  CI/CD-переменных проекта (см. ниже), `masked` (не выводятся в логи) и
  `protected` (доступны только защищённым веткам).
* **Изоляция окружений.** Отдельные state-ключи, отдельные resource_group и
  environment-названия на env; джобы разных окружений не видят и не трогают
  state друг друга.

### CI/CD-переменные проекта

| Переменная | masked | protected | Что это в контуре |
|---|---|---|---|
| `TF_STATE_ENDPOINT` | - | - | адрес S3-совместимого хранилища, видимый с job-контейнеров |
| `AWS_ACCESS_KEY_ID` | да | да | ключ доступа хранилища (для YOS - Yandex API-ключ) |
| `AWS_SECRET_ACCESS_KEY` | да | да | секрет ключа (для YOS - Yandex API-ключ) |
| `YC_TOKEN` | да | да | токен с правами на folder (provider читает его из env) |
| `YC_CLOUD_ID` | - | да | id облака YC |
| `YC_FOLDER_ID` | - | да | id folder'а, где создаются ресурсы (provider читает из env) |


