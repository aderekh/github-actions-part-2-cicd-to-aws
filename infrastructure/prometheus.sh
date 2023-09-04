#!/bin/bash
sudo yum install -y awscli #надо чтоб сервер мог опрашивать aws о инстансах
sudo bash -c 'tee /etc/yum.repos.d/prometheus.repo <<EOF
[prometheus]
name=prometheus
baseurl=https://packagecloud.io/prometheus-rpm/release/el/7/x86_64
repo_gpgcheck=1
enabled=1
gpgkey=https://packagecloud.io/prometheus-rpm/release/gpgkey
       https://raw.githubusercontent.com/lest/prometheus-rpm/master/RPM-GPG-KEY-prometheus-rpm
gpgcheck=1
metadata_expire=300
EOF'
sudo yum -y install prometheus2 node_exporter
sudo bash -c 'cat > /etc/prometheus/prometheus.yml <<CONFIG_CONTENT
global:
  scrape_interval: 2m
  scrape_timeout: 1m
scrape_configs:
  - job_name: "ec2"
    ec2_sd_configs:
      - region: us-east-1
        port: 9100
    relabel_configs:
      - source_labels: [__meta_ec2_tag_Name]
        regex: "dos13-aderekh-env"
        action: keep
CONFIG_CONTENT'
sudo systemctl restart prometheus node_exporter
sudo systemctl enable prometheus node_exporter