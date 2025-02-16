job "win-test" {
  datacenters = ["dc1"]

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "windows"
  }

  group "win-group" {
    network {
      port "http" {
        to = 8080
      }
    }

    service {
      name = "www"
      port = "http"
    }

    task "win-task" {
      driver = "docker"
      config {
        image = "ollijanatuinen/aspnet-win2025:sample"
        hostname = "test"
        isolation = "process"
      }
    }
  }
}
