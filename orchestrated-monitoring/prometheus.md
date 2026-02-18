# Prometheus  Installation

- This document provides the **"One-Shot"** commands to deploy Prometheus via Helm and retrieve access credentials.

## 1. Fast Deploy
---------------

Run these commands to prepare your environment and install the Prometheus stack.

Bash

```
# Install Helm (if not already installed)
# sudo snap install helm --classic

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/prometheus\
  --namespace monitoring\
  --create-namespace

```

## 2. Access & Verification
-------------------------

Once the pods are **Running**, use these snippets to access the Prometheus expression browser (UI):

### Access UI (Port-Forward)

Prometheus Server usually runs on port 9090.

Bash

```
kubectl port-forward --namespace monitoring service/prometheus-server 9090:80

```

**URL:** [http://localhost:9090](https://www.google.com/search?q=http://localhost:9090)

### Check Node Exporter

Prometheus automatically starts collecting metrics from your nodes using **Node Exporter**.

Bash

```
kubectl get pods -n monitoring -l "app.kubernetes.io/name=prometheus"

```

* * * * *

## 3. External Access (Load Balancer)
-----------------------------------

To expose the Prometheus UI externally:

Bash

```
kubectl patch svc prometheus-server -n monitoring -p '{"spec": {"type": "LoadBalancer"}}'

kubectl get svc prometheus-server -n monitoring -w

```

* * * * *
