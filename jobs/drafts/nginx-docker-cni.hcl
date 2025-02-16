# Abandoned because needs installing and configuring CNI plugins
job "nginx-test" {
  datacenters = ["dc1"]
  namespace   = "test"

  group "nginx-group" {
    network {
      mode   = "cni/bridge-no-nat"
      port "http" {}
    }

    service {
      name = "www"
      port = "http"
      address_mode = "alloc"
    }

    task "nginx" {
      driver = "docker"
      config {
        image = "nginx:latest"
      }
    }
  }
}
