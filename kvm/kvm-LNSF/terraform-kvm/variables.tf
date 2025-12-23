variable "host_ip" {
  description = "IP address of the KVM host"
  type        = string
  default     = "10.42.0.240"
}

variable "host_user" {
  description = "Username on the KVM host"
  type        = string
  default     = "dpro"
}

variable "ssh_public_key" {
  description = "SSH public key for all VMs"
  type        = string
  sensitive   = true
}

variable "root_password" {
  description = "Root password for all VMs"
  type        = string
  sensitive   = true
}

variable "user_password" {
  description = "Password for user account on all VMs"
  type        = string
  sensitive   = true
}
