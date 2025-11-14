# **📘 End-to-End MERN Application Deployment & Monitoring**

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

## 🔧 2. Server Configuration -- Ansible

-   Install Node.js, npm
-   Clone TravelMemory app
-   Install backend & frontend dependencies
-   Configure environment variables
-   Setup MongoDB
-   Configure Prometheus, Grafana, MongoDB Exporter

## 📡 3. Observability (Prometheus)

Backend Metrics: - API Latency\
- Request Count\
- Error Rate\
MongoDB Metrics via Exporter

    /metrics endpoint enabled

## 📊 4. Grafana Dashboards

Dashboards for: - Backend metrics - MongoDB performance - System metrics
Alerts for: - High error rate - High latency - MongoDB performance
issues

## 🧪 5. Performance Analysis

Collected metrics show: - P95 latency \~120ms - Stable MongoDB
connections (\< 20) - Occasional DB latency spikes - Memory peak alerts
analyzed & fixed

## 📝 Sample .env (redacted)

    MONGO_URL=mongodb://<DB_IP>:27017/travelmemory
    JWT_SECRET=<REDACTED>
    PORT=3000
    REACT_APP_API_URL=http://<WEB_IP>:3000

## 📐 Architecture Diagram

Stored in: `docs/architecture-diagram.png`

## 🛠 Issues & Fixes

-   MongoDB remote access fixed via bindIP + SG rules\
-   Prometheus path corrected\
-   Grafana datasource fixed\
-   Memory issues analyzed

## 📬 Submission Info

Include: - GitHub repo link - Name + contact - PDF or README - Grafana
screenshots

## ✅ Conclusion

A complete automated MERN deployment with: - Terraform infra - Ansible
configuration - Prometheus + Grafana monitoring - Alerts + performance
metrics
