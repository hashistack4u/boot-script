data_dir = "/opt/hashistack/nomad/data"

tls {
  http = false
  rpc = true
  ca_file = "/opt/hashistack/tls/client.crt"
  cert_file = "/opt/hashistack/tls/client.crt"
  key_file = "/opt/hashistack/tls/client.key"
  verify_https_client = false
  rpc_upgrade_mode = false
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics = true
  prometheus_metrics = true
}

plugin "docker" {
  config {
    allow_privileged = false
    volumes {
      enabled = false
    }
  }
}
