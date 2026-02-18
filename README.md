🚀 PulseView-ObserveX: Enterprise Observability Stack
=====================================================

**PulseView-ObserveX** is a production-grade monitoring and observability framework engineered to provide deep visibility into cloud-native environments. This project demonstrates a holistic approach to monitoring, spanning from hardware-level metrics to application-layer insights and cross-cloud integration with AWS.

📑 Table of Contents
--------------------

-   [Architectural Overview](https://github.com/GhanshyamRamole/PulseView-Monitoring-and-Observability/new/main?filename=README.md#-architectural-overview)

-   [Core Features](https://github.com/GhanshyamRamole/PulseView-Monitoring-and-Observability/new/main?filename=README.md#-core-features)

-   [The Tech Stack](https://github.com/GhanshyamRamole/PulseView-Monitoring-and-Observability/new/main?filename=README.md#-the-tech-stack)

-   [Deployment Strategies](https://github.com/GhanshyamRamole/PulseView-Monitoring-and-Observability/new/main?filename=README.md#-deployment-strategies)

-   [Advanced Configurations](https://github.com/GhanshyamRamole/PulseView-Monitoring-and-Observability/new/main?filename=README.md#%EF%B8%8F-advanced-configurations)

-   [Operational Intelligence](https://github.com/GhanshyamRamole/PulseView-Monitoring-and-Observability/new/main?filename=README.md#-operational-intelligence)

* * * * *

🏗 Architectural Overview
-------------------------

The stack is designed for multi-layered data ingestion, ensuring no blind spots in the infrastructure.

-   **Infrastructure Layer:** Provisioned via **Terraform** on AWS EC2.

-   **Orchestration Layer:** Metrics collection from **Kubernetes** nodes and pods using **cAdvisor** and **Kube-State-Metrics**.

-   **Cloud Integration:** Bi-directional observability with **AWS CloudWatch** to monitor ECS and ALB metrics.

-   **Persistence & Visualization:** **Prometheus** serves as the high-cardinality TSDB, with **Grafana** providing the single pane of glass for visualization.

* * * * *

🌟 Core Features
----------------

-   **End-to-End Monitoring:** Unified visibility across System (Node Exporter), Container (cAdvisor), and Application metrics.

-   **Infrastructure as Code (IaC):** Automated provisioning of AWS resources using Terraform.

-   **Automated Provisioning:** Shell-based automation for zero-touch Grafana datasource configuration and Prometheus installation.

-   **Cloud-Native Integration:** Native Prometheus Service Discovery (SD) for Kubernetes pods and AWS ECS tasks.

-   **Proactive Alerting:** Sophisticated alerting via **AlertManager** with multi-channel routing (Email, PagerDuty, etc.).

* * * * *

🛠 The Tech Stack
-----------------

| **Category** | **Tools** |
| --- | --- |
| **Infrastucture** | AWS (EC2, ECS, ALB), Terraform, Kubernetes |
| **Data Ingestion** | Prometheus, Node Exporter, cAdvisor, CloudWatch Exporter |
| **Visualization** | Grafana (Automated Provisioning) |
| **Alerting** | AlertManager (SMTP/Global integration) |
| **Automation** | Bash Scripts, Docker Compose |

* * * * *

🚀 Deployment Strategies
------------------------

### 1\. Containerized Stack (Quick Start)

Deploy the entire monitoring suite using orchestrated containers.

Bash

```
# Execute the deployment master script
chmod +x deploy-monitoring.sh
./deploy-monitoring.sh

```

**Services Mapping:**

-   **Prometheus:** `9090` (Configured with 200h retention)

-   **Grafana:** `3000` (Default: admin/admin)

-   **AlertManager:** `9093`

-   **Node Exporter:** `9100`

### 2\. Standalone Automation

For legacy or bare-metal environments, use the modular installation scripts:

-   `install_prometheus.sh`: Bootstraps Prometheus v3.4.2.

-   `install_grafana.sh`: Handles repo configuration and auto-provisions datasources.

-   `install_node_exporter.sh`: Sets up systemd services for persistent node monitoring.

* * * * *

⚙️ Advanced Configurations
--------------------------

### Hybrid Kubernetes & AWS Scrape Jobs

The Prometheus configuration is optimized for hybrid environments, automatically discovering Kubernetes pods and EC2/ECS instances.

YAML

```
# Snippet from prometheus.yml
scrape_configs:
  - job_name: 'my-webapp-k8s'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: keep
        regex: my-webapp

```

### Enterprise Alerting Logic

Configured for high reliability with resolution timeouts and inhibited noise.

-   **Severity Mapping:** Inhibits `warning` alerts when a `critical` alert of the same name is active.

-   **Routing:** Global SMTP configuration for centralized incident management.

* * * * *

📊 Operational Intelligence
---------------------------

### Golden Signals & Metrics

The environment is pre-configured to track the **Four Golden Signals**:

-   **Latency:** `http_request_duration_seconds`

-   **Traffic:** `rate(http_requests_total[5m])`

-   **Errors:** App-specific error counters

-   **Saturation:** CPU and Memory utilization via `node_exporter`

### AWS CloudWatch Integration

The stack bridges the gap between on-prem/k8s and AWS-managed services, exporting ECS and ALB metrics directly into the Prometheus ecosystem.

* * * * *

✅ Best Practices Implemented
----------------------------

-   **Security:** Non-root users for service execution (node_exporter/prometheus).

-   **Automation:** Automatic firewall configuration (UFW/Firewalld) during installation.

-   **Lifecycle Management:** Prometheus enabled with `--web.enable-lifecycle` for hot-reloads.
