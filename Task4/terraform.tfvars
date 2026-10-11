# Docker-совместимый сокет podman machine на этой машине.
# На другой машине заменить на свой путь (podman machine inspect ... PodmanSocket.Path)
# или на "unix:///var/run/docker.sock" при использовании Docker Desktop.
docker_host = "unix:///var/folders/vl/bd3tdr8n1qx802w_bmt7kxbw0000gp/T/podman/podman-machine-default-api.sock"

project_prefix = "future2"

network_public_subnet   = "10.80.10.0/24"
network_internal_subnet = "10.80.20.0/24"

gateway_host_port   = 18080
lakehouse_host_port = 19000

vm_size = {
  gateway   = { memory = 256, cpu_shares = 512 }
  portal    = { memory = 256, cpu_shares = 512 }
  catalog   = { memory = 512, cpu_shares = 1024 }
  lakehouse = { memory = 512, cpu_shares = 1024 }
}
