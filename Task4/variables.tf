variable "docker_host" {
  description = "Docker-совместимый сокет (здесь — сокет podman machine)"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "project_prefix" {
  description = "Префикс имён ресурсов, изолирует landing zone проекта"
  type        = string
  default     = "future2"
}

variable "network_public_subnet" {
  description = "Подсеть публичного сегмента (ingress / NAT)"
  type        = string
  default     = "10.80.10.0/24"
}

variable "network_internal_subnet" {
  description = "Подсеть внутреннего сегмента (платформа, БД — без внешнего доступа)"
  type        = string
  default     = "10.80.20.0/24"
}

variable "gateway_host_port" {
  description = "Host-порт для NAT-публикации шлюза (ingress)"
  type        = number
  default     = 8080
}

variable "lakehouse_host_port" {
  description = "Host-порт для NAT-публикации lakehouse-ноды"
  type        = number
  default     = 9000
}

variable "image_nginx" {
  type    = string
  default = "docker.io/library/nginx:1.27-alpine"
}

variable "image_postgres" {
  type    = string
  default = "docker.io/library/postgres:16-alpine"
}

variable "vm_size" {
  description = "Размер «виртуальных машин»: лимит памяти (МБ) и доля CPU на роль"
  type = map(object({
    memory     = number
    cpu_shares = number
  }))
  default = {
    gateway   = { memory = 256, cpu_shares = 512 }
    portal    = { memory = 256, cpu_shares = 512 }
    catalog   = { memory = 512, cpu_shares = 1024 }
    lakehouse = { memory = 512, cpu_shares = 1024 }
  }
}

variable "db_password" {
  description = "Пароль служебной БД каталога"
  type        = string
  default     = "future2_catalog"
  sensitive   = true
}
