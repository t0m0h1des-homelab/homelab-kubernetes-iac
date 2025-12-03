terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.66.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.pve_endpoint

  api_token = "${var.pve_user}!${var.pve_token_id}=${var.pve_token_secret}"

  insecure = true

  ssh {
    agent = true
  }
}

variable "pve_endpoint" {}
variable "pve_user" {}
variable "pve_token_id" {}
variable "pve_token_secret" {}
variable "ssh_public_key" {}

resource "proxmox_virtual_environment_vm" "k8s_node" {
  name      = var.vm_name
  node_name = var.target_node

  clone {
    vm_id = var.template_id
  }

  agent {
    enabled = true
  }

  cpu {
    cores = var.vm_cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.vm_memory
  }

  disk {
    datastore_id = var.vm_disk_storage
    interface    = "scsi0"
    size         = var.vm_disk_size
    file_format  = "raw"
  }

  initialization {
    ip_config {
      ipv4 {
        address = var.vm_ipv4_address
        gateway = var.vm_gateway
      }
    }

    user_account {
      username = "root"
      keys     = [var.ssh_public_key]
    }
  }

  network_device {
    bridge = var.vm_network_bridge
  }
}
