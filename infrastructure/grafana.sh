#!/bin/bash
wget -q -O gpg.key https://rpm.grafana.com/gpg.key
sudo rpm --import gpg.key
sudo bash -c 'cat > /etc/yum.repos.d/grafana.repo <<CONFIG_CONTENT
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
CONFIG_CONTENT'
sudo dnf install grafana -y
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
sudo systemctl stop grafana-server
sudo cp -r grafana/* /etc/grafana
sudo cp /home/ec2-user/grafana.db /var/lib/grafana/grafana.db
sudo dnf install awscli -y
sudo aws configure set default.region us-east-1
prometheus_ip=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].[PrivateIpAddress]" --filters "Name=tag:Name,Values=dos13_aderekh_prometheus" "Name=instance-state-name,Values=running" --output text)
sudo yum install sqlite -y
sudo sqlite3 /var/lib/grafana/grafana.db <<EOF
UPDATE data_source SET url = 'http://${prometheus_ip}:9090/' WHERE name = 'Prometheus';
EOF
sudo systemctl start grafana-server