data_dir = "/opt/hashistack/consul"

tls {
  defaults {
    verify_incoming = true
    verify_outgoing = true
    verify_server_hostname = true
    ca_file = "/opt/hashistack/tls/client.crt"
    cert_file = "/opt/hashistack/tls/client.crt"
    key_file = "/opt/hashistack/tls/client.key"
  }
}
