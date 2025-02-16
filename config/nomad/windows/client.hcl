client {
  enabled = true
  cni_path = "C:\\Program Files\\containerd\\cni\\bin"

  drain_on_shutdown {
    deadline = "5m"
    force = true
    ignore_system_jobs = false
  }

  options {
    "driver.allowlist" = "docker"
    "env.denylist" = "CONSUL_ENCRYPT_KEY,AZURE_CLIENT_SECRET"
    "user.denylist" = "ContainerAdministrator"
  }

  reserved {
    cores = "0"
    memory = 1024
    disk = 2048
    reserved_ports = "1-1024"
  }
}
