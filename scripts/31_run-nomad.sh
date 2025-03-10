SCRIPT_DIR=$(dirname "$0")
if [ -d "/opt/hashistack/nomad" ]; then
  exit 0
fi

set -a
source /etc/hashistack.env
sudo mkdir -p /etc/nomad.d
sudo cp -f $SCRIPT_DIR/../config/nomad/* /etc/nomad.d/

# Generate cluster config
CLUSTER_CONFIG='client {server_join {retry_join = ['
declare -a ALL_SERVERS=(${HOSTNAME::-1}1 ${HOSTNAME::-1}2 ${HOSTNAME::-1}3)
for i in "${!ALL_SERVERS[@]}"; do
  if [ "${ALL_SERVERS[$i]}" == "$HOSTNAME" ]; then
    continue
  fi
  CLUSTER_CONFIG+="\"${ALL_SERVERS[$i]}.${DNS_DOMAIN_NAME}:4647\""
  if (( $i < "${#ALL_SERVERS[@]}" - 1 )); then
    CLUSTER_CONFIG+=","
  fi
done
CLUSTER_CONFIG+=']}}'
echo -e "$CLUSTER_CONFIG" | sudo tee /etc/nomad.d/cluster.hcl

sudo chown -R nomad:hashistack /etc/nomad.d/
sudo chmod 0750 /etc/nomad.d
sudo chmod 0640 /etc/nomad.d/*

sudo -i -u root env SCRIPT_DIR=$SCRIPT_DIR bash << 'EOF'
set -a
source /etc/hashistack.env
mkdir -p /opt/hashistack/nomad/data
mkdir -p /opt/hashistack/nomad/data/plugins
sudo cp -f $SCRIPT_DIR/../certs/containerd-driver /opt/hashistack/nomad/data/plugins/
# nomad agent $NOMAD_ROLE -config /etc/nomad.d/ -dc $CONSUL_DATACENTER $NOMAD_EXTRA_PARAM
EOF
