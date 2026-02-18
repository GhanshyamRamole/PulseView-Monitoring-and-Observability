#!/bin/bash

# ==============================================================================
# Grafana Installer and Auto-Provisioning of data source
# ==============================================================================

set -e
set -u

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

read -p "Enter Prometheus Server IP or Hostname: " PROM_SERVER_URL

echo -e "${GREEN}Starting Grafana Installation & Provisioning...${NC}"

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Run as root (sudo)${NC}" 
   exit 1
fi

if [ -f /etc/redhat-release ] || [ -f /etc/system-release ]; then
    echo "Configuring YUM repository..."
    cat <<EOF > /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF
    yum install -y grafana
elif [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
    echo "Configuring APT repository..."
    apt-get update && apt-get install -y apt-transport-https software-properties-common wget
    mkdir -p /etc/apt/keyrings/
    wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list
    apt-get update && apt-get install -y grafana
else
    echo -e "${RED}Unsupported OS.${NC}"
    exit 1
fi

echo "Provisioning Prometheus Data Source..."
mkdir -p /etc/grafana/provisioning/datasources/

cat <<EOF > /etc/grafana/provisioning/datasources/prometheus.yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: $PROM_SERVER_URL
    isDefault: true
    editable: true
EOF

echo "Starting Grafana Server..."
systemctl daemon-reload
systemctl enable --now grafana-server

if command -v firewall-cmd &> /dev/null && systemctl is-active --quiet firewalld; then
    firewall-cmd --add-port=3000/tcp --permanent
    firewall-cmd --reload
elif command -v ufw &> /dev/null; then
    ufw allow 3000/tcp
fi

echo -e "${GREEN}Grafana is now running and Provisioned!${NC}"
echo "URL: http://$(hostname -I | awk '{print $1}'):3000"
echo "Data Source 'Prometheus' has been automatically added."
