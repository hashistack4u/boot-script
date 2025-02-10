sudo cp /mnt/bootscript/systemd/nomad.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable nomad.service
sudo systemctl start nomad.service
