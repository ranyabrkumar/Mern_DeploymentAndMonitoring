# ** End-to-End MERN Application Deployment & Monitoring**

### **Terraform \| Ansible \| Prometheus \| Grafana \| AWS**

This project demonstrates a **production-grade deployment** of the MERN
TravelMemory application using Infrastructure-as-Code, configuration
management, and observability tooling.

##  Project Overview

This repository automates deployment and monitoring of the
**TravelMemory** MERN application:\
 https://github.com/ranyabrkumar/Mern_DeploymentAndMonitoring.git

The project provisions AWS infrastructure, deploys the MERN stack,
configures MongoDB, exposes Prometheus metrics, and sets up Grafana
dashboards & alerting.

##  Repository Structure

    terraform/
    ansible/
    monitoring/
    docs/
    sample.env

##  1. Infrastructure -- Terraform

-   Provision EC2 (Web + MongoDB)
-   Default VPC + Internet Gateway
-   Route table for internet
-   Security groups for web & db
-   Terraform outputs show public IPs
-   [Main.tf](https://github.com/ranyabrkumar/Mern_DeploymentAndMonitoring/blob/main/IaC/main.tf)
- <img width="931" height="116" alt="image" src="https://github.com/user-attachments/assets/71893729-1551-4881-921d-0e0f6ab17938" />

## 2. Server Configuration -- Ansible

-   Install Node.js, npm
-   Clone TravelMemory app
-   Install backend & frontend dependencies
-   Configure environment variables
-   Setup MongoDB
-   Configure Prometheus, Grafana, MongoDB Exporter
-   [dbserver.yml](https://github.com/ranyabrkumar/Mern_DeploymentAndMonitoring/blob/main/ansible/playbooks/dbserver.yml)
-   [webserver.yml](https://github.com/ranyabrkumar/Mern_DeploymentAndMonitoring/blob/main/ansible/playbooks/webserver.yml)

## 3. Observability (Prometheus)

Backend Metrics: 
- API Latency\
- Request Count\
- Error Rate\
  <p align="center">
  <img src="https://github.com/user-attachments/assets/2b880009-7887-461a-807c-b32cea8b3653" width="700"/>
  <img src="https://github.com/user-attachments/assets/f985f96a-01b1-47df-9153-b4e2af058ef0" width="700"/>
  </p>

  
MongoDB Metrics via Exporter

    /metrics endpoint enabled
<p align="center">
  <img src="https://github.com/user-attachments/assets/f3ff30c4-b584-4529-b716-21e62dfd51a4" width="700"/>  
</p>
- [prometheus.yml](https://github.com/ranyabrkumar/Mern_DeploymentAndMonitoring/blob/main/ansible/playbooks/prometheus.yml)
  
## 4. Grafana Dashboards

Dashboards for: - Backend metrics - MongoDB performance - System metrics
Alerts for: - High error rate - High latency - MongoDB performance
issues
<p align="center">
  <img src="https://github.com/user-attachments/assets/cb873a24-abc5-4205-8e27-26b6232f3463" width="700"/>
 
<img src="https://github.com/user-attachments/assets/cfe8e04b-654e-403d-b0c7-1851129cb11a" width="700"/>
<img src="https://github.com/user-attachments/assets/eede9b6a-c796-4ea0-b536-678f66110996" width="700"/>
<img src="https://github.com/user-attachments/assets/3a1824e2-6497-49b4-b8b4-1dcd35c64547" width="700"/>
 
 <img src="https://github.com/user-attachments/assets/5d4c327b-2eb3-49f1-a92a-3cebfbbedca1" width="700"/>
 <img src="https://github.com/user-attachments/assets/b8820f97-5d85-4754-b73f-8f06ca635dfc" width="700"/>
 <img src="https://github.com/user-attachments/assets/46796577-4d6a-4fbb-a865-792867cfc206" width="700"/>
 <img src="https://github.com/user-attachments/assets/0f01193b-01d4-47c1-a70f-be37ba55b00f" width="700"/>
 <img src="https://github.com/user-attachments/assets/0d3594e2-1c86-416e-b1f5-8b45e86f9d1c" width="700"/>
 <img src="https://github.com/user-attachments/assets/f679e005-67f6-4deb-8469-7d75677fdfa5" width="700"/>
 <img src="https://github.com/user-attachments/assets/d819d28f-af4f-447a-9117-998a45dda0f6" width="700"/>
 <img src="https://github.com/user-attachments/assets/161df409-304e-4a59-bf53-69c8bed724ae" width="700"/>
</p>
- [Grafana.yml](https://github.com/ranyabrkumar/Mern_DeploymentAndMonitoring/blob/main/ansible/playbooks/grafana.yml)

## 5. Performance Analysis

Collected metrics show: - P95 latency \~120ms - Stable MongoDB
connections (\< 20) - Occasional DB latency spikes - Memory peak alerts
analyzed & fixed

## Sample .env (redacted)

    MONGO_URL=mongodb://<DB_IP>:27017/travelmemory
    JWT_SECRET=<REDACTED>
    PORT=3000
    REACT_APP_API_URL=http://<WEB_IP>:3000

## Architecture Diagram

Stored in: `docs/architecture-diagram.png`

## Issues & Fixes

-   MongoDB remote access fixed via bindIP + SG rules\
-   Prometheus path corrected\
-   Grafana datasource fixed\
-   Memory issues analyzed

## Submission Info

Include: - GitHub repo link - Name + contact - PDF or README - Grafana
screenshots

## Conclusion

A complete automated MERN deployment with: - Terraform infra - Ansible
configuration - Prometheus + Grafana monitoring - Alerts + performance
metrics
