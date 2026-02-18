# Adding client to prometheus.yml

read -p "Enter Client name: " CLIENT_NAME
read -p "Enter Client IP address to discover by prometheus: " CLIENT_IP

grep -q "$CLIENT_NAME" /etc/hosts || echo "$CLIENT_IP $CLIENT_NAME" >> /etc/hosts

cat <<EOF >> /etc/prometheus/prometheus.yml
  - job_name: '$CLIENT_NAME'
    static_configs:
      - targets: ['$CLIENT_NAME:9100']
EOF

systemctl reload prometheus
