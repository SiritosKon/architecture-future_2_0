terraform {
  required_version = ">= 1.5"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = var.docker_host
}

# --- Сети: публичный сегмент (ingress/NAT) и внутренний (без внешнего доступа) ---
resource "docker_network" "public" {
  name   = "${var.project_prefix}-public"
  driver = "bridge"
  ipam_config {
    subnet = var.network_public_subnet
  }
}

resource "docker_network" "internal" {
  name     = "${var.project_prefix}-internal"
  driver   = "bridge"
  internal = true
  ipam_config {
    subnet = var.network_internal_subnet
  }
}

# --- Диски: том под БД каталога и том под объектное хранилище ---
resource "docker_volume" "catalog_data" {
  name = "${var.project_prefix}-catalog-data"
}

resource "docker_volume" "lake_data" {
  name = "${var.project_prefix}-lake-data"
}

# --- Образы ---
resource "docker_image" "nginx" {
  name         = var.image_nginx
  keep_locally = true
}

resource "docker_image" "postgres" {
  name         = var.image_postgres
  keep_locally = true
}

# --- «VM»: шлюз (ingress через NAT) ---
resource "docker_container" "gateway" {
  name       = "${var.project_prefix}-gateway"
  image      = docker_image.nginx.image_id
  memory     = var.vm_size["gateway"].memory
  cpu_shares = var.vm_size["gateway"].cpu_shares
  restart    = "unless-stopped"

  networks_advanced {
    name = docker_network.public.name
  }

  ports {
    internal = 80
    external = var.gateway_host_port
  }
}

# --- «VM»: портал самообслуживания (внутренний сегмент) ---
resource "docker_container" "portal" {
  name       = "${var.project_prefix}-portal"
  image      = docker_image.nginx.image_id
  memory     = var.vm_size["portal"].memory
  cpu_shares = var.vm_size["portal"].cpu_shares
  restart    = "unless-stopped"

  networks_advanced {
    name = docker_network.internal.name
  }
}

# --- «VM»: БД каталога данных (внутренний сегмент, диск) ---
resource "docker_container" "catalog_db" {
  name       = "${var.project_prefix}-catalog-db"
  image      = docker_image.postgres.image_id
  memory     = var.vm_size["catalog"].memory
  cpu_shares = var.vm_size["catalog"].cpu_shares
  restart    = "unless-stopped"

  env = [
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=catalog",
  ]

  volumes {
    volume_name    = docker_volume.catalog_data.name
    container_path = "/var/lib/postgresql/data"
  }

  networks_advanced {
    name = docker_network.internal.name
  }
}

# --- «VM»: lakehouse-нода объектного хранилища (диск + NAT-публикация) ---
resource "docker_container" "lakehouse" {
  name       = "${var.project_prefix}-lakehouse"
  image      = docker_image.nginx.image_id
  memory     = var.vm_size["lakehouse"].memory
  cpu_shares = var.vm_size["lakehouse"].cpu_shares
  restart    = "unless-stopped"

  volumes {
    volume_name    = docker_volume.lake_data.name
    container_path = "/usr/share/nginx/html"
  }

  networks_advanced {
    name = docker_network.public.name
  }

  ports {
    internal = 80
    external = var.lakehouse_host_port
  }
}
