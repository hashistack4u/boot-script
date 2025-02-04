ui = true
disable_mlock = true

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_cert_file = "/opt/hashistack/tls/server.crt"
  tls_key_file  = "/opt/hashistack/tls/server.key"
  tls_client_ca_file = "/opt/hashistack/tls/client.crt"
  tls_min_version = "tls12"
  telemetry {
    unauthenticated_metrics_access = true
  }
}

seal "azurekeyvault" {}
