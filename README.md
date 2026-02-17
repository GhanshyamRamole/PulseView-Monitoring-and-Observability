# PulseView-ObserveX (Monitoring and Observability)

Set up comprehensive, production-grade monitoring for your applications using Prometheus, Grafana, Node Exporter, cAdvisor, and AlertManager.

In today’s cloud-native ecosystem, observability is crucial for maintaining reliable infrastructure. In this project, I built an observability lab where I monitored a Kubernetes cluster running on AWS EC2 instances using Prometheus and Grafana. Additionally, I deployed a sample application as a pod in the cluster. The infrastructure and deployments were automated using Terraform, docker-compose, and Docker.

---
## Objectives
- Deploy a Kubernetes cluster on AWS EC2 instances
- Install Prometheus and Grafana using Helm charts
- Deploy a sample app as a pod
- Use Prometheus to collect cluster metrics
- Visualize metrics with Grafana dashboards
---

## 🚀 Tools & Technologies

- **AWS EC2** - for hosting the Kubernetes nodes
- **Kubernetes** - for cluster orchestration
- **Terraform** - for Infrastructure as Code (IaC)
- **docker-compose** - for managing Kubernetes packages
  
  ## monitoring tools
  
- **Prometheus** – Metrics collection and time-series database  
- **Grafana** – Visualization and alerting dashboards  
- **Node Exporter** – System-level metrics (CPU, memory, disk)  
- **cAdvisor** – Container-level metrics  
- **AlertManager** – Alert routing and notifications  
- **Custom Dashboards** – Tailored views for your applications  

---

## 🧱 Architecture

![Architecture](https://www.scylladb.com/wp-content/uploads/datadog-diagram-2.png)

```
Your App → Prometheus → Grafana → Beautiful Dashboards
↓           ↓           ↓
System Metrics → Alerts → Notifications
```

---

## 🛠️ Prerequisites

- instance with docker and kubernetes installed 
- you web app https://github.com/GhanshyamRamole/Fun.git
- A modern web browser

---
## Provision Infrastructure with Terraform
- I used Terraform to provision EC2 instances with appropriate security groups,
- IAM roles, and SSH access. The EC2 instances were launched in a specific VPC and subnet .
```bash
provider "aws" {
  region = "us-east-1"
}
```
``` bash
resource "aws_instance" "k8s_node" {
  ami           = "ami-xxxxxxx"
  instance_type = "t2.medium"
}
```
---
## 📦 Setup Instructions

### Step 1: Start Monitoring Stack

```bash
docker-compose up -d
docker-compose ps
```

**Ports:**
- Prometheus → `9090`
- Grafana → `3000`
- Node Exporter → `9100`
- cAdvisor → `8080`
- AlertManager → `9093`

---

### Step 2: Access the Tools

- **Prometheus**: [http://localhost:9090](http://localhost:9090)  
  - Check `Status` → `Targets`  
  - Try query: `up`

- **Grafana**: [http://localhost:3000](http://localhost:3000)  
  - Login: `admin` / `admin`  
  - Explore dashboards

- **Node Exporter**: [http://localhost:9100/metrics](http://localhost:9100/metrics)  
- **cAdvisor**: [http://localhost:8080](http://localhost:8080)

---

### Step 3: Configure Grafana Data Source

1. Go to ⚙️ → **Data Sources**  
2. Click **Add data source**  
3. Choose **Prometheus**  
4. Set URL: `http://prometheus:9090`  
5. Click **Save & Test**

---

### Step 4: Create Dashboards

#### Option 1: Import Prebuilt Dashboard

- ➕ → **Import**  
- Enter ID: `1860` (Node Exporter Full)  
- Select Prometheus as data source  
- Click **Import**

#### Option 2: Create Custom Dashboard

1. ➕ → **Dashboard** → Add Panel  
2. Select Prometheus as data source  
3. Enter query: `up`  
4. Click **Apply** and **Save**

---

### Step 5: Monitor Your Web Application

```bash
git clone https://github.com/GhanshyamRamole/Fun.git
cd /FUN
## deploy using k8s-manifest-file
kubectl apply -f deployment.yml
kubectl apply -f service.yml
kubectl get ingress.yml
```

- Check Prometheus Targets: [http://localhost:9090/targets](http://localhost:9090/targets)  
- Import `webapp-dashboard.json` or create a custom dashboard

---

### Step 6: Set Up Alerts (Optional)

Create an `alert_rules.yml` file:

```yaml
groups:
  - name: webapp_alerts
    rules:
      - alert: WebAppDown
        expr: up{job="my-webapp-local"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Web application is down"
          description: "The web application has been down for more than 1 minute."

      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100) > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 2 minutes."
```

---

## 📊 Useful Metrics to Explore

### System Metrics

- `node_cpu_seconds_total` – CPU usage  
- `node_memory_MemAvailable_bytes` – Available memory  
- `node_filesystem_free_bytes` – Disk usage  

### Container Metrics

- `container_cpu_usage_seconds_total`  
- `container_memory_usage_bytes`  
- `container_network_receive_bytes_total`  

### App Metrics

- `http_requests_total`  
- `http_request_duration_seconds`  
- `process_cpu_seconds_total`

---

## ☁️ AWS & Kubernetes Integration (Optional)

### Monitor ECS Services

```bash
kubectl apply -f aws-cloudwatch-integration.yml
```

- Update Prometheus configuration  
- Import ECS dashboards: CPU, memory, task count, ALB metrics

### Monitor Kubernetes

```bash
kubectl apply -f https://github.com/kubernetes/kube-state-metrics/examples/standard
```

**Import these Grafana dashboards:**

- ID `315`: Kubernetes Cluster  
- ID `8588`: Deployment Metrics

---

## 🧠 Common PromQL Queries

**CPU Usage**

```promql
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100)
```

**Memory Usage**

```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

**App Uptime**

```promql
up{job="my-webapp-local"}
```

---

## 🧪 Troubleshooting

### Services Not Starting

```bash
docker-compose logs prometheus
docker-compose restart
docker-compose ps
```

### No Data in Grafana

- Verify Prometheus targets are `UP`  
- Run queries in Prometheus  
- Test Grafana data source

### Missing App Metrics

```bash
curl http://localhost:3001/metrics
```

> Ensure your app is instrumented using `prom-client`:  
```bash
npm install prom-client
```

### AlertManager Issues

```bash
docker-compose logs alertmanager
```

> Validate alert rules in Prometheus dashboard

---

## ✅ Best Practices

- Clear and meaningful dashboard titles  
- Use consistent color schemes  
- Alert only on meaningful thresholds  
- Focus on **Golden Signals**: Latency, Traffic, Errors, Saturation  

---

## 🏗️ Production Considerations

### Security

- Change default passwords  
- Enable HTTPS for Prometheus and Grafana  
- Restrict access with firewall/VPC rules  

### Scalability

- Use external storage (e.g., Thanos, Cortex)  
- Use federated Prometheus for large-scale infrastructure  

### Reliability

- Monitor Prometheus and Grafana uptime  
- Backup configurations and dashboards  
- Configure high availability for critical services

---

## 🧹 Clean Up

```bash
docker-compose down
docker-compose down -v
docker image prune
```
## Conclusion
This observability lab helped me understand the complete pipeline from provisioning infrastructure with Terraform to setting up monitoring with Prometheus and Grafana. Deploying a real application added practical value to the monitoring setup.


