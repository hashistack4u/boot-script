sudo systemctl stop consul.service
sudo rm -rf /opt/hashistack/consul/

sudo systemctl stop vault.service
sudo rm -rf /opt/hashistack/vault/

sudo rm -rf /opt/hashistack/tls/
