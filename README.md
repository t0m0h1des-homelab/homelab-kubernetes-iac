[![Japanese](https://img.shields.io/badge/Language-Japanese-blue)](README_ja.md)

# Home Lab Kubernetes Infrastructure (IaC)

![License](https://img.shields.io/badge/license-MIT-blue)
![Terraform](https://img.shields.io/badge/Terraform-1.9+-purple)
![Ansible](https://img.shields.io/badge/Ansible-2.16+-red)
![Nix](https://img.shields.io/badge/Nix-Reproducible-blue)

A complete **Infrastructure as Code (IaC)** repository to provision a Kubernetes cluster on **Proxmox VE 9**.
This project demonstrates a modern, reproducible approach to home lab infrastructure, featuring network isolation via a Virtual Router (NFV) and declarative configuration management.

## 🚀 Key Features

* **Reproducible Environment:** Uses **Nix & Direnv** to manage development tools (Terraform, Ansible, kubectl). Eliminates manual installation and version mismatch issues on the host machine.
* **Network Function Virtualization (NFV):** Deploys a Fedora-based Virtual Router to isolate the Kubernetes cluster within an internal network. Establishes secure communication via NAT and IP Masquerading.
* **Modern Proxmox Support:** Utilizes the **bpg/proxmox** provider for full compatibility with Proxmox VE 9+, resolving API authentication issues found in legacy providers.
* **Immutable Infrastructure:** Provisions VMs using **Fedora Cloud Base Images** via Cloud-Init, ensuring clean and consistent deployments every time.
* **Declarative Configuration:**
    * **Terraform:** Manages VM lifecycle (Compute, Network, Storage).
    * **Ansible:** Manages OS configuration, Router setup, and Kubernetes (Kubeadm) bootstrapping.

## 🏗️ Architecture

```mermaid
graph TD
    User[Developer PC] -->|Nix/Direnv| DevEnv[Dev Shell]
    DevEnv -->|Terraform| PVE[Proxmox VE 9]

    subgraph Proxmox Virtual Environment
        Router[<b>Virtual Router</b><br>Fedora Cloud]
        K8s[<b>K8s Node</b><br>Fedora Cloud]

        Router -- WAN (vmbr0) --- HomeLAN((Home LAN))
        Router -- Internal (vmbr1) --> K8s
    end

    DevEnv -->|Ansible| Router
    DevEnv -->|Ansible (via Router)| K8s
````

## 🛠️ Tech Stack & Rationale

| Category | Technology | Reason for Selection |
| :--- | :--- | :--- |
| **Dev Environment** | **Nix + Direnv** | To guarantee tool version consistency across different machines and keep the host OS clean. |
| **Provisioning** | **Terraform** | Industry standard for infrastructure lifecycle management. Used `bpg/proxmox` for v9 compatibility. |
| **Configuration** | **Ansible** | Agentless and lightweight. Manages everything from Router network settings to K8s bootstrapping consistently. |
| **Network** | **Linux Router (NFV)** | To build an isolated network environment (SDN) entirely via IaC without modifying physical network hardware configuration. |
| **Virtualization** | **Proxmox VE** | Powerful, open-source Type-1 hypervisor. |
| **OS** | **Fedora Cloud** | Provides up-to-date kernel features and SELinux integration, making it ideal for modern container workloads. |

## ⚡ Quick Start

### Prerequisites

  * Nix installed
  * Direnv installed
  * Proxmox VE 8.x or 9.x environment

### 1\. Setup Development Environment

Simply enter the directory. Nix will automatically setup Terraform, Ansible, and other tools.

```bash
direnv allow
```

### 2\. Configure Credentials

Copy the example file and define your Proxmox credentials.

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit pve_endpoint, pve_user, token, ssh_key, router_ip, etc.
```

### 3\. Provision Infrastructure (Terraform)

Create the Virtual Router and Kubernetes Node VMs.

```bash
terraform init
terraform plan
terraform apply
```

### 4\. Configure Network & Cluster (Ansible)

Create the inventory file and execute the playbooks in order: **Router Setup → Cluster Construction**.

```bash
cp inventory.ini.example inventory.ini
# Edit IP addresses for Router and K8s Node

# 1. Setup Virtual Router (Enable NAT/Firewall)
ansible-playbook -i inventory.ini router.yml

# 2. Build Kubernetes Cluster & Install ArgoCD
ansible-playbook -i inventory.ini site.yml
```

## 🔜 Roadmap

  * [x] **ArgoCD** integration for GitOps-based application deployment
  * [ ] **MetalLB** configuration for internal Layer 2 Load Balancing
  * [ ] **Renovate** implementation for automated dependency updates
  * [ ] **Cloudflare Tunnel** integration for secure remote access without opening ports
  * [ ] **Longhorn** or **Rook/Ceph** deployment for distributed block storage and backups
  * [ ] **Prometheus & Grafana** stack for cluster monitoring and alerting
  * [ ] **Loki** or **Fluent Bit** for centralized log aggregation
  * [ ] **Sealed Secrets** or **External Secrets Operator** for managing secrets in GitOps

## 📝 License

This project is licensed under the MIT License.
