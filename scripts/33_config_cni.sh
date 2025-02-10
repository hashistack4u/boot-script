# https://developer.hashicorp.com/nomad/docs/networking/cni
SCRIPT_DIR=$(dirname "$0")

sudo mkdir -p /opt/cni/config
sudo cp $SCRIPT_DIR/../config/cni/* /opt/cni/config/

sudo systemctl restart nomad.service

