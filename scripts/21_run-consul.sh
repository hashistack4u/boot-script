SCRIPT_DIR=$(dirname "$0")
if [ -d "/opt/hashistack/consul" ]; then
  exit 0
fi

set -a
source /etc/hashistack.env
sudo mkdir -p /etc/consul.d
sudo cp -f $SCRIPT_DIR/../config/consul/* /etc/consul.d/

# Generate cluster config
CLUSTER_CONFIG='retry_join = ['
declare -a ALL_SERVERS=(${HOSTNAME::-1}1 ${HOSTNAME::-1}2 ${HOSTNAME::-1}3)
for i in "${!ALL_SERVERS[@]}"; do
  if [ "${ALL_SERVERS[$i]}" == "$HOSTNAME" ]; then
    continue
  fi
  CLUSTER_CONFIG+="\"${ALL_SERVERS[$i]}.${DNS_DOMAIN_NAME}\""
  if (( $i < "${#ALL_SERVERS[@]}" - 1 )); then
    CLUSTER_CONFIG+=","
  fi
done
CLUSTER_CONFIG+=']'
echo -e "$CLUSTER_CONFIG" | sudo tee /etc/consul.d/cluster.hcl

sudo chown -R consul:hashistack /etc/consul.d/
sudo chmod 0750 /etc/consul.d
sudo chmod 0640 /etc/consul.d/*

sudo -i -u consul bash << 'EOF'
set -a
source /etc/hashistack.env
mkdir -p /opt/hashistack/consul
consul agent -config-dir=/etc/consul.d/ -datacenter $CONSUL_DATACENTER -encrypt $CONSUL_ENCRYPT_KEY -recursor $DNS_SERVER1 -recursor $DNS_SERVER2
EOF
