SCRIPT_DIR=$(dirname "$0")
if [ -d "/opt/hashistack/coredns" ]; then
  return
fi

set -a
source /etc/hashistack.env

sudo mkdir -p /etc/coredns
sudo cp -f $SCRIPT_DIR/../config/coredns/* /etc/coredns/

# Generate CoreDNS config
# Implement simple multi-tenancy by rewriting queries like:
# "api.marketing.service.consul" to "api-marketing.service.consul"
# That way we can have marketing tenant containers using DNS suffix "marketing.service.consul"
# and thy can simply connect to "http://api"
COREFILE='.:53 {\n  errors\n'
COREFILE+="  forward . ${DNS_SERVER1} ${DNS_SERVER2}\n}\n\n"
COREFILE+='consul.:53 {\n  log\n  errors\n  rewrite name regex ^([^.]+)\.([^.]+)\.(.+)\.$ {1}-{2}.{3}\n  forward . 127.0.0.1:8600\n}\n'
echo -e "$COREFILE" | sudo tee /etc/coredns/Corefile

sudo chown -R coredns:hashistack /etc/coredns
sudo chmod 0750 /etc/coredns
sudo chmod 0640 /etc/coredns/*

sudo -i -u coredns bash << 'EOF'
set -a
source /etc/hashistack.env
mkdir -p /opt/hashistack/coredns
EOF

sudo cp /mnt/bootscript/systemd/coredns.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable coredns.service
sudo systemctl start coredns.service
