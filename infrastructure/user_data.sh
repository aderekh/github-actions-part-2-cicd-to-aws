#!/bin/bash
sudo useradd -m -s /bin/bash prometheus
sudo curl -L -O  https://github.com/prometheus/node_exporter/releases/download/v0.17.0/node_exporter-0.17.0.linux-amd64.tar.gz

sudo tar -xzvf node_exporter-0.17.0.linux-amd64.tar.gz
sudo mv node_exporter-0.17.0.linux-amd64 /home/prometheus/node_exporter
sudo rm node_exporter-0.17.0.linux-amd64.tar.gz
sudo chown -R prometheus:prometheus /home/prometheus/node_exporter

# Add node_exporter as systemd service
sudo bash -c 'cat > /etc/systemd/system/node_exporter.service <<CONFIG_CONTENT
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
ExecStart=/home/prometheus/node_exporter/node_exporter
[Install]
WantedBy=default.target
CONFIG_CONTENT'

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter