# Task 4. Облачная инфраструктура (IaaS, Terraform)

## Содержимое

| Файл | Что внутри |
|---|---|
| [`diagram.png`](diagram.png) | Диаграмма автоматизации развёртывания (что в Terraform, что вручную) |
| [`main.tf`](main.tf) | Описание инфраструктуры (сети, тома, образы, контейнеры) |
| [`variables.tf`](variables.tf) | Определение переменных |
| [`outputs.tf`](outputs.tf) | Вывод ключевых параметров |
| [`terraform.tfvars`](terraform.tfvars) | Значения переменных |
| [`apply-screenshot.png`](apply-screenshot.png) | Скриншот результата `terraform apply` |
| [`justification.md`](justification.md) | Обоснование конфигурации |
| [`diagram.drawio`](diagram.drawio) | Исходник диаграммы |

## Что разворачивается

Мини-ландшафт облачной платформы данных в модели IaaS, смоделированный Docker-провайдером Terraform (локально, через docker-совместимый сокет podman machine). Соответствие облачным примитивам: контейнер = VM, том = Disk, bridge-сеть = Network, публикация порта = NAT.

- **Сети:** `future2-public` (NAT, 10.80.10.0/24) и `future2-internal` (internal, 10.80.20.0/24)
- **Диски:** `future2-catalog-data`, `future2-lake-data`
- **VM (контейнеры):** `gateway` (ingress, NAT 18080), `portal` (внутр.), `catalog-db` (postgres + диск), `lakehouse` (хранилище + диск, NAT 19000)

Детали выбора параметров — в [`justification.md`](justification.md).

## Как запустить

```bash
cd Task4
terraform init
terraform plan
terraform apply
# удалить всё, что создано:
terraform destroy
```

> `docker_host` в `terraform.tfvars` указывает на сокет podman machine этой машины. На другой машине заменить на свой путь (`podman machine inspect ... PodmanSocket.Path`) или на `unix:///var/run/docker.sock` для Docker Desktop.

Результат проверки `terraform init` → `plan` → `apply` (создано 10 ресурсов) — на скриншоте [`apply-screenshot.png`](apply-screenshot.png).
