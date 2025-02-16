plugin "docker" {
  config {
    allow_privileged = false
    volumes {
      enabled = false
    }
  }
}
