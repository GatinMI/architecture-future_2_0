# Образ для CI/CD-пайплайна.
#
# Terraform 1.5.7 + провайдер Yandex Cloud v0.239.0, заложенный в неявный
# локальный mirror (/usr/local/share/terraform/plugins).
#
# Сборка:
#   docker build -t future20/terraform-yc:1.5.7 .

FROM hashicorp/terraform:1.5.7

ARG YANDEX_PROVIDER_VERSION=0.239.0
# SHA256 пакета провайдера - сверяется при сборке, защита от подмены пакета
ARG YANDEX_PROVIDER_SHA256=7d941cc5295dcead47034bdb08b2773b3084d7a178c01a35fd6dd40550a8d862

# Официальный образ имеет ENTRYPOINT ["terraform"], который ломает запуск
# скриптов CI (раннер вызывает sh -c). Для CI-образа entrypoint сбрасываем,
# команды terraform в джобах вызываются явно.
ENTRYPOINT []
CMD ["terraform"]

RUN set -eux; \
    plugin_dir="/usr/local/share/terraform/plugins/registry.terraform.io/yandex-cloud/yandex/${YANDEX_PROVIDER_VERSION}/linux_amd64"; \
    mkdir -p "${plugin_dir}"; \
    wget -qO /tmp/tpy.zip "https://github.com/yandex-cloud/terraform-provider-yandex/releases/download/v${YANDEX_PROVIDER_VERSION}/terraform-provider-yandex_${YANDEX_PROVIDER_VERSION}_linux_amd64.zip"; \
    echo "${YANDEX_PROVIDER_SHA256}  /tmp/tpy.zip" | sha256sum -c -; \
    unzip -o -j /tmp/tpy.zip -d "${plugin_dir}"; \
    chmod 0755 "${plugin_dir}/terraform-provider-yandex_v${YANDEX_PROVIDER_VERSION}"; \
    rm -f /tmp/tpy.zip
