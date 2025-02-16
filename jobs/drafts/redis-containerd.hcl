# Abandoned because needs installing and configuring containerd plugin
job "redis" {
  datacenters = ["dc1"]
  namespace   = "test"

  group "redis-group" {
    network {
      port "redis" {
        to = 6379
      }
    }

    service {
      name = "redis"
      port = "redis"
      address_mode = "alloc"
    }

    task "redis-task" {
      driver = "containerd-driver"
      config {
        image       = "redis:alpine"
        hostname    = "foobar"
        seccomp     = true
        cwd         = "/home/redis"
        cpuset_cpus = "0-1"
        cpuset_mems = "0"
      }

      resources {
        cpu        = 500
        memory     = 256
        memory_max = 512
      }
    }
  }
}
