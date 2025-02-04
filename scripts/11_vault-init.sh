SCRIPT_DIR=$(dirname "$0")

if [ "${HOSTNAME: -1}" != "1" ]; then
  echo "Please run this script in server number one"
  exit 1
fi

# Configure Vault
if [ ! -d "/opt/hashistack/tls" ]; then
  set -a
  source /etc/hashistack.env

  mkdir -p /opt/hashistack/tls
  SAN_STRING="subjectAltName=DNS:${HOSTNAME}.${DNS_DOMAIN_NAME},DNS:${HOSTNAME::-1}2.${DNS_DOMAIN_NAME},DNS:${HOSTNAME::-1}3.${DNS_DOMAIN_NAME}"
  openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
    -out /opt/hashistack/tls/server.crt \
    -keyout /opt/hashistack/tls/server.key \
    -subj "/CN=HashiStack For You, Server certificate" \
    -addext $SAN_STRING
  chmod g+r /opt/hashistack/tls/server.key

  openssl req -x509 -newkey rsa:4096 -sha256 -days 90 -nodes \
    -out /opt/hashistack/tls/client.crt \
    -keyout /opt/hashistack/tls/client.key \
    -subj "/CN=HashiStack For You, Client certificate" \
    -addext "$SAN_STRING,DNS:server.$CONSUL_DATACENTER.consul"
  chmod g+r /opt/hashistack/tls/client.key

  cp -f /opt/hashistack/tls/* $SCRIPT_DIR/../certs/
fi

if [ ! -d "/opt/hashistack/vault/data" ]; then
  sudo -i -u vault bash << 'EOF'
  set -a
  source /etc/hashistack.env
  mkdir -p /opt/hashistack/vault/data
  vault server -config=/mnt/bootscript/config/vault-init.hcl &
  VAULT_PID=$!
  sleep 3s
  export VAULT_SKIP_VERIFY=true
  vault operator init -recovery-shares=1 -recovery-threshold=1 -format json
  sleep 15s
  kill -s 3 $VAULT_PID
EOF
fi
