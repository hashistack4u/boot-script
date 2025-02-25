# Job which registers service to Consul DNS and can be queried with:
# dig @127.0.0.1 www-nginx.example.service.dc1.consul / dig @127.0.0.1 www-nginx.example.service.consul
job "nginx-test" {
  datacenters = ["dc1"]
  namespace   = "example"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  group "nginx-group" {
    network {
      port "http" {}
      dns {
        searches = ["example.service.consul"]
      }
    }

    task "nginx" {
      driver = "docker"
      config {
        image = "nginx:latest"
        network_mode = "example"
      }

      service {
        name = "www-nginx-example"
        port = "http"
        address_mode = "driver"
      }
    }
  }
}
