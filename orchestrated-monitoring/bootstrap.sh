#!/bin/bash

# ==============================================================================
# PulseView-ObserveX: Enterprise Monitoring Bootstrap Script
# ==============================================================================

set -e

NAMESPACE="monitoring"
RELEASE_NAME="pulseview-stack"
RETENTION_TIME="200h"
STORAGE_SIZE="20Gi"
GRAFANA_PASSWORD="admin" 

echo "🚀 Starting Industry-Level Monitoring Deployment..."

echo "[INFO] Configuring Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "[INFO] Deploying Prometheus, Grafana, and Alertmanager..."
helm upgrade --install $RELEASE_NAME prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --create-namespace \
  --set prometheus.prometheusSpec.retention=$RETENTION_TIME \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]=ReadWriteOnce \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=$STORAGE_SIZE \
  --set grafana.adminPassword=$GRAFANA_PASSWORD \
  --set grafana.persistence.enabled=true \
  --set grafana.persistence.size=5Gi

echo "[INFO] Exposing Services via LoadBalancer..."
kubectl patch svc ${RELEASE_NAME}-grafana -n $NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}'
kubectl patch svc ${RELEASE_NAME}-prometheus -n $NAMESPACE -p '{"spec": {"type": "LoadBalancer"}}'

echo "------------------------------------------------"
echo "✅ Deployment Successful!"
echo "Prometheus Retention: $RETENTION_TIME"
echo "Grafana URL: $(kubectl get svc ${RELEASE_NAME}-grafana -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):3000"
echo "Grafana User: admin"
echo "Grafana Password: $GRAFANA_PASSWORD"
echo "------------------------------------------------"
