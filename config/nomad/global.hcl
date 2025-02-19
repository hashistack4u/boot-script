data_dir = "/opt/hashistack/nomad/data"
disable_update_check = true

tls {
  http = true
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
