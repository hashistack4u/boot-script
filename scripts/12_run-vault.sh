SCRIPT_DIR=$(dirname "$0")
if [ ! -d "/opt/hashistack/tls" ]; then
  if [ "${HOSTNAME: -1}" == "1" ]; then
    echo "Please run vault-init.sh first"
    exit 1
  fi
  mkdir -p /opt/hashistack/tls
  cp -f $SCRIPT_DIR/../certs/* /opt/hashistack/tls/
fi

set -a
source /etc/hashistack.env

sudo mkdir -p /etc/vault.d
sudo cp -f $SCRIPT_DIR/../config/vault/* /etc/vault.d/

# Generate raft config
RAFT_CONFIG='storage "raft" {\n  path = "/opt/hashistack/vault/data"\n  performance_multiplier = 1\n\n'
ALL_SERVERS=(${HOSTNAME::-1}1 ${HOSTNAME::-1}2 ${HOSTNAME::-1}3)
for SERVER in ${ALL_SERVERS[@]}; do
  if [ "$SERVER" == "$HOSTNAME" ]; then
    continue
  fi
  RAFT_CONFIG+="  retry_join {\n"
  RAFT_CONFIG+="    leader_api_addr = \"https://${SERVER}.${DNS_DOMAIN_NAME}:8200\"\n"
  RAFT_CONFIG+="    leader_ca_cert_file = \"/opt/hashistack/tls/server.crt\"\n"
  RAFT_CONFIG+="    leader_client_cert_file = \"/opt/hashistack/tls/client.crt\"\n"
  RAFT_CONFIG+="    leader_client_key_file = \"/opt/hashistack/tls/client.key\"\n"
  RAFT_CONFIG+="    insecure_skip_verify = false\n"
  RAFT_CONFIG+="  }\n"
done
RAFT_CONFIG+="}\n"
echo -e "$RAFT_CONFIG" | sudo tee /etc/vault.d/raft.hcl

sudo chown -R vault:hashistack /etc/vault.d
sudo chmod 0750 /etc/vault.d
sudo chmod 0640 /etc/vault.d/*

sudo -i -u vault bash << 'EOF'
set -a
source /etc/hashistack.env
mkdir -p /opt/hashistack/vault/data
#vault server -config=/etc/vault.d
EOF
