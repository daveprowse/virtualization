variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "root_password" {
  description = "Root password for VMs"
  type        = string
  sensitive   = true
}

variable "user_password" {
  description = "User password for VMs"
  type        = string
  sensitive   = true
}

variable "network_name" {
  description = "Libvirt network name (existing network, READ-ONLY reference)"
  type        = string
  default     = "10-network"
}

variable "kvm_images_dir" {
  description = "Directory for KVM images"
  type        = string
}


variable "debian_image_name" {
  description = "Debian cloud image filename"
  type        = string
}

variable "debian_version" {
  description = "Debian version number"
  type        = string
  default     = "13"
}

variable "ubuntu_image_name" {
  description = "Ubuntu cloud image filename"
  type        = string
}

variable "ubuntu_version" {
  description = "Ubuntu version number"
  type        = string
  default     = "24"
}

variable "centos_image_name" {
  description = "CentOS cloud image filename"
  type        = string
}

variable "centos_version" {
  description = "CentOS version number"
  type        = string
  default     = "10"
}

variable "fedora_image_name" {
  description = "Fedora cloud image filename"
  type        = string
}

variable "fedora_version" {
  description = "Fedora version number"
  type        = string
  default     = "43"
}

variable "opensuse_image_name" {
  description = "OpenSUSE cloud image filename"
  type        = string
}

variable "opensuse_version" {
  description = "OpenSUSE version number"
  type        = string
  default     = "15"
}

# VM Display Names
variable "debserver_display_name" {
  description = "Display name for Debian Server"
  type        = string
  default     = ""  # Will be computed if empty
}

variable "debclient_display_name" {
  description = "Display name for Debian Client"
  type        = string
  default     = ""  # Will be computed if empty
}

variable "ubuntu_server_display_name" {
  description = "Display name for Ubuntu Server"
  type        = string
  default     = ""  # Will be computed if empty
}

variable "centos_server_display_name" {
  description = "Display name for CentOS Server"
  type        = string
  default     = ""  # Will be computed if empty
}

variable "fedora_client_display_name" {
  description = "Display name for Fedora Workstation"
  type        = string
  default     = ""  # Will be computed if empty
}

variable "opensuse_display_name" {
  description = "Display name for OpenSUSE"
  type        = string
  default     = ""  # Will be computed if empty
}

# Debian Server variables
variable "debserver_hostname" {
  description = "Hostname for Debian Server"
  type        = string
  default     = "debserver"
}

variable "debserver_ip" {
  description = "IP address for Debian Server"
  type        = string
  default     = "10.0.2.51"
}

# Debian Client variables
variable "debclient_hostname" {
  description = "Hostname for Debian Client"
  type        = string
  default     = "debclient"
}

variable "debclient_ip" {
  description = "IP address for Debian Client"
  type        = string
  default     = "10.0.2.52"
}

# Ubuntu Server variables
variable "ubuntu_server_hostname" {
  description = "Hostname for Ubuntu Server"
  type        = string
  default     = "ubuntu-server"
}

variable "ubuntu_server_ip" {
  description = "IP address for Ubuntu Server"
  type        = string
  default     = "10.0.2.53"
}

# CentOS Server variables
variable "centos_server_hostname" {
  description = "Hostname for CentOS Server"
  type        = string
  default     = "centos-server"
}

variable "centos_server_ip" {
  description = "IP address for CentOS Server"
  type        = string
  default     = "10.0.2.61"
}

# Fedora Client variables
variable "fedora_client_hostname" {
  description = "Hostname for Fedora Client"
  type        = string
  default     = "fed-client"
}

variable "fedora_client_ip" {
  description = "IP address for Fedora Client"
  type        = string
  default     = "10.0.2.62"
}

# OpenSUSE variables
variable "opensuse_hostname" {
  description = "Hostname for OpenSUSE"
  type        = string
  default     = "opensuse"
}

variable "opensuse_ip" {
  description = "IP address for OpenSUSE"
  type        = string
  default     = "10.0.2.71"
}
