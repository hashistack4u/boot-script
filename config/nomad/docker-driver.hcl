plugin "docker" {
  config {
    allow_privileged = false
    allow_runtimes = ["runc"]
    volumes {
      enabled = false
    }
  }
}
