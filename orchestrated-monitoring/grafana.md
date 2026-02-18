# Grafana Minimalist Installation


This document provides the **"One-Shot"** commands to deploy Grafana via Helm and retrieve access credentials.

## 1. Fast Deploy
---------------

- Run these commands to add the repository and install the chart. Using a dedicated namespace is best practice for observability tools.

Bash

```
helm repo add grafana https://grafana.github.io/helm-charts

helm repo update

helm install grafana grafana/grafana\
  --namespace monitoring\
  --create-namespace

```

## 2. Credentials & Access
------------------------

Once the pods are **Running**, use these snippets to gain entry:

### Get Admin Password

The password is automatically generated and stored in a Kubernetes secret.

Bash

```
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo

```

3. External Access (Load Balancer)
-----------------------------------

To expose Grafana to the internet:

Bash

```
kubectl patch svc grafana -n monitoring -p '{"spec": {"type": "LoadBalancer"}}'

kubectl get svc grafana -n monitoring -w
```
