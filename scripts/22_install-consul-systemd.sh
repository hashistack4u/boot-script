sudo cp /mnt/bootscript/systemd/consul.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable consul.service
sudo systemctl start consul.service
