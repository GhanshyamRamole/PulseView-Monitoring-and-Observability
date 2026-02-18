#!/bin/bash
# ==============================================================================
# Prometheus  Installer 
# ==============================================================================

set -e

PROM_VERSION="3.4.2"
USER="prometheus"
PROM_DIR_CONF="/etc/prometheus"
PROM_DIR_LIB="/var/lib/prometheus"
TEMP_DIR="/tmp/prometheus_install"

if [[ $EUID -ne 0 ]]; then
   echo "Error: Run as root (sudo)" 
   exit 1
fi

echo "Step 1: Installing dependencies..."
if [ -f /etc/debian_version ]; then
    apt-get update -y && apt-get install -y wget tar
elif [ -f /etc/redhat-release ] || [ -f /etc/system-release ]; then
    yum install -y wget tar
fi

if ! id "$USER" &>/dev/null; then
    useradd --no-create-home --shell /bin/false "$USER"
fi

mkdir -p "$PROM_DIR_CONF" "$PROM_DIR_LIB"

echo "Step 2: Downloading Prometheus v${PROM_VERSION}..."
rm -rf "$TEMP_DIR" && mkdir -p "$TEMP_DIR"
wget -q -P "$TEMP_DIR" "https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
tar -xzf "$TEMP_DIR/prometheus-${PROM_VERSION}.linux-amd64.tar.gz" -C "$TEMP_DIR"

EXTRACTED_PATH="$TEMP_DIR/prometheus-${PROM_VERSION}.linux-amd64"

echo "Step 3: Installing binaries and assets..."

cp "$EXTRACTED_PATH/prometheus" "$EXTRACTED_PATH/promtool" /usr/local/bin/

if [ -d "$EXTRACTED_PATH/consoles" ]; then
    cp -r "$EXTRACTED_PATH/consoles" "$PROM_DIR_CONF/"
fi

if [ -d "$EXTRACTED_PATH/console_libraries" ]; then
    cp -r "$EXTRACTED_PATH/console_libraries" "$PROM_DIR_CONF/"
fi

if [ ! -f "$PROM_DIR_CONF/prometheus.yml" ]; then
    cp "$EXTRACTED_PATH/prometheus.yml" "$PROM_DIR_CONF/"
fi

chown -R "$USER":"$USER" "$PROM_DIR_CONF" "$PROM_DIR_LIB"
chown "$USER":"$USER" /usr/local/bin/prometheus /usr/local/bin/promtool

cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file=$PROM_DIR_CONF/prometheus.yml \\
    --storage.tsdb.path=$PROM_DIR_LIB/ \\
    --web.console.templates=$PROM_DIR_CONF/consoles \\
    --web.console.libraries=$PROM_DIR_CONF/console_libraries
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now prometheus

rm -rf "$TEMP_DIR"

echo "------------------------------------------------"
echo "Prometheus is successfully installed!"
echo "Check status: systemctl status prometheus"
echo "Access UI: http://$(hostname -I | awk '{print $1}'):9090"
