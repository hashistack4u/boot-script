job "win-test" {
  datacenters = ["dc1"]

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "windows"
  }

  group "win-group" {
    task "win-task" {
      driver = "containerd-driver"
      config {
        image = "mcr.microsoft.com/dotnet/aspnet:9.0-nanoserver-ltsc2025"
        hostname = "test"
      }
    }
  }
}
