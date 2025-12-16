variable "proxmox_endpoint" {
  description = "Proxmox API endpoint (e.g., https://proxmox.example.com:8006)"
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox API username (e.g., root@pam)"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = false
}

variable "proxmox_ssh_username" {
  description = "SSH username for Proxmox host"
  type        = string
  default     = "root"
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "proxmox_datastore_vm" {
  description = "Proxmox datastore for VM disks (can be ZFS/LVM)"
  type        = string
  default     = "local-zfs"
}

variable "proxmox_datastore_iso" {
  description = "Proxmox datastore for ISO images (must be directory-based)"
  type        = string
  default     = "local"
}

variable "proxmox_datastore_snippets" {
  description = "Proxmox datastore for cloud-init snippets (must be directory-based)"
  type        = string
  default     = "local"
}

variable "proxmox_bridge" {
  description = "Network bridge on Proxmox"
  type        = string
  default     = "vmbr2"
}

variable "gateway" {
  description = "Network gateway"
  type        = string
  default     = "10.42.0.1"
}

variable "vm_password" {
  description = "Password for the sa user on VMs"
  type        = string
  sensitive   = true
}

variable "ssh_keys" {
  description = "List of SSH public keys for the sa user"
  type        = list(string)
  default     = []
}
