# Job which registers service to Consul DNS and can be queried with:
# dig @127.0.0.1 www.service.dc1.consul / dig @127.0.0.1 www.service.consul
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
