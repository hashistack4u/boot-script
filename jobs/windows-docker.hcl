# Job which registers service to Consul DNS and can be queried with:
# dig @127.0.0.1 www-aspnet.example.service.dc1.consul / dig @127.0.0.1 www-aspnet.example.service.consul
job "win-test" {
  datacenters = ["dc1"]
  namespace   = "example"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "windows"
  }

  group "win-group" {
    network {
      port "http" {
        to = 8080
      }
      /*
      FixMe: There looks to be bug in Windows so this causes error:
      "failed to build mount for resolv.conf: open /etc/resolv.conf: The system cannot find the file specified"
      dns {
        searches = ["example.service.consul"]
      }
      */
    }

    task "win-task" {
      driver = "docker"
      config {
        image = "ollijanatuinen/aspnet-win2025:sample"
        hostname = "test"
        isolation = "process"
      }

      service {
        name = "www-aspnet-example"
        port = "http"
        address_mode = "driver"
      }
    }
  }
}
