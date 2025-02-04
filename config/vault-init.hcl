disable_mlock = true

listener "tcp" {
  address = "127.0.0.1:8200"
  cluster_address = "127.0.0.1:8201"
  tls_cert_file = "/opt/hashistack/tls/server.crt"
  tls_key_file  = "/opt/hashistack/tls/server.key"
}

seal "azurekeyvault" {}

storage "raft" {
  path    = "/opt/hashistack/vault/data"
  performance_multiplier = 1
}
