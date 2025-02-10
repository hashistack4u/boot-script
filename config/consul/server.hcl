server = true
bootstrap_expect = 3
client_addr = "0.0.0.0"

ui_config = {
  "enabled"=true
}

connect {
  enabled = true
}

telemetry {
  "prometheus_retention_time" = "372h"
}

ports {
  dns = 53
  http = -1
  https = 8501
}

tls {
  https {
    verify_incoming = false
    verify_outgoing = false
    ca_file = ""
    cert_file = "/opt/hashistack/tls/server.crt"
    key_file = "/opt/hashistack/tls/server.key"
  }
}

acl {
  enabled = true
  default_policy = "allow"
  enable_token_persistence = true
}
