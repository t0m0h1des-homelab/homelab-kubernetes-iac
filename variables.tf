variable "pve_endpoint" {
  description = "Proxmox API Endpoint (e.g., https://192.168.1.10:8006/)"
  type        = string
}

variable "pve_user" {
  description = "Proxmox User (e.g., terraform-admin@pve)"
  type        = string
}

variable "pve_token_id" {
  description = "Proxmox API Token ID"
  type        = string
}

variable "pve_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH Public Key for VM access"
  type        = string
}

variable "vm_name" {
  description = "The name of the Kubernetes Node VM"
  type        = string
  default     = "k8s-node-01"
}

variable "target_node" {
  description = "Target Proxmox Node Name"
  type        = string
  default     = "z840"
}

variable "template_id" {
  description = "ID of the VM template to clone (Fedora Cloud Base)"
  type        = number
  default     = 9000
}

variable "vm_cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Memory size in MB"
  type        = number
  default     = 4096
}

variable "vm_disk_storage" {
  description = "Storage ID for the OS disk"
  type        = string
  default     = "local-lvm"
}

variable "vm_disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "router_name" {
  description = "Name of the Router VM"
  type        = string
  default     = "v-router"
}

variable "router_wan_ip" {
  description = "Router WAN IP (Home LAN side)"
  type        = string
  default     = "192.168.1.2/24"
}

variable "router_lan_ip" {
  description = "Router LAN IP (Internal side)"
  type        = string
  default     = "10.0.0.1/24"
}

variable "vm_ipv4_address" {
  description = "Static IPv4 address in CIDR notation"
  type        = string
  default     = "10.0.0.10/24"
}

variable "vm_gateway" {
  description = "Gateway IP address (Internal Router IP)"
  type        = string
  default     = "10.0.0.1"
}

variable "physical_gateway" {
  description = "Gateway IP of the physical home router"
  type        = string
  default     = "192.168.1.1"
}
