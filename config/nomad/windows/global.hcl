data_dir = "C:\\hashistack\\nomad"
log_level = "TRACE"

tls {
  http = true
  rpc = true
  ca_file = "C:\\hashistack\\tls\\client.crt"
  cert_file = "C:\\hashistack\\tls\\client.crt"
  key_file = "C:\\hashistack\\tls\\client.key"
  verify_https_client = false
  rpc_upgrade_mode = false
}

plugin "docker" {
  config {
    volumes {
      enabled = false
    }
  }
}
