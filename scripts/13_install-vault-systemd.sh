sudo cp /mnt/bootscript/systemd/vault.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable vault.service
sudo systemctl start vault.service
