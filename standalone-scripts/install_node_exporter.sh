#!/bin/bash

# ==============================================================================
# Node Exporter  Installer
# ==============================================================================

set -e

NODE_EXPORTER_VERSION="1.9.0"
USER="node_exporter"
BIN_DIR="/usr/local/bin"
TEMP_DIR="/tmp/node_exporter_install"

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Installing Node Exporter v${NODE_EXPORTER_VERSION}...${NC}"

if ! id "$USER" &>/dev/null; then
    useradd --no-create-home --shell /bin/false "$USER"
fi

mkdir -p "$TEMP_DIR" && cd "$TEMP_DIR"
wget -q "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
tar -xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

cp "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" "$BIN_DIR/"
chown "$USER":"$USER" "$BIN_DIR/node_exporter"

cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=$BIN_DIR/node_exporter \\
    --collector.mountstats \\
    --collector.logind \\
    --collector.processes \\
    --collector.systemd
Restart=always

[Install]
WantedBy=multi-user.target
EOF

if command -v firewall-cmd &> /dev/null && systemctl is-active --quiet firewalld; then
    firewall-cmd --add-port=9100/tcp --permanent
    firewall-cmd --reload
elif command -v ufw &> /dev/null; then
    ufw allow 9100/tcp
fi

systemctl daemon-reload
systemctl enable --now node_exporter

echo -e "${GREEN}Node Exporter is up and running on port 9100!${NC}"
