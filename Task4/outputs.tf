output "networks" {
  description = "Созданные сети и их подсети"
  value = {
    public   = "${docker_network.public.name} (${var.network_public_subnet})"
    internal = "${docker_network.internal.name} (${var.network_internal_subnet}, internal)"
  }
}

output "volumes" {
  description = "Созданные тома (диски)"
  value = [
    docker_volume.catalog_data.name,
    docker_volume.lake_data.name,
  ]
}

output "containers" {
  description = "Созданные «VM» (контейнеры) и их роли"
  value = {
    gateway   = docker_container.gateway.name
    portal    = docker_container.portal.name
    catalog   = docker_container.catalog_db.name
    lakehouse = docker_container.lakehouse.name
  }
}

output "published_endpoints" {
  description = "Точки входа, опубликованные через NAT на host"
  value = {
    gateway   = "http://localhost:${var.gateway_host_port}"
    lakehouse = "http://localhost:${var.lakehouse_host_port}"
  }
}
