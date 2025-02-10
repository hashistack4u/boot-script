server {
  enabled = true
  bootstrap_expect = 3
}

consul {
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  tags = ["admin"]
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
  ca_file = "/opt/hashistack/tls/server.crt"
}
