terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.89.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = var.proxmox_insecure
  
  ssh {
    agent    = true
    username = var.proxmox_ssh_username
  }
}

# Download Ubuntu 24.04 cloud image
resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = var.proxmox_datastore_iso
  node_name    = var.proxmox_node

  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"

  overwrite           = true
  overwrite_unmanaged = true
  upload_timeout      = 600
  verify              = true
}

# ============================================================
# STANDALONE VMs (Non-MicroK8s)
# ============================================================

# Prometheus Server 1
resource "proxmox_virtual_environment_vm" "prom1" {
  name        = "PROM1-10.42.88.1"
  description = "Standalone Ubuntu Server - prom1"
  node_name   = var.proxmox_node
  vm_id       = 2101

  agent {
    enabled = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = var.proxmox_datastore_vm
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 32
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge = var.proxmox_bridge
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  initialization {
    datastore_id = var.proxmox_datastore_vm
    
    ip_config {
      ipv4 {
        address = "10.42.88.1/16"
        gateway = var.gateway
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init_prom1.id
  }

  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }
}

# Prometheus Server 2
resource "proxmox_virtual_environment_vm" "prom2" {
  name        = "PROM2-10.42.88.2"
  description = "Standalone Ubuntu Server - prom2"
  node_name   = var.proxmox_node
  vm_id       = 2102

  agent {
    enabled = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = var.proxmox_datastore_vm
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 32
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge = var.proxmox_bridge
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  initialization {
    datastore_id = var.proxmox_datastore_vm
    
    ip_config {
      ipv4 {
        address = "10.42.88.2/16"
        gateway = var.gateway
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_init_prom2.id
  }

  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }
}

# ============================================================
# MICROK8S CLUSTER VMs
# ============================================================

# Controller VM
resource "proxmox_virtual_environment_vm" "controller" {
  name        = "microk8s-controller-10.42.88.120"
  description = "MicroK8s Controller Node"
  node_name   = var.proxmox_node
  vm_id       = 2120

  agent {
    enabled = true
  }

  cpu {
    cores = 8
    type  = "host"
  }

  memory {
    dedicated = 16384
  }

  disk {
    datastore_id = var.proxmox_datastore_vm
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 32
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge = var.proxmox_bridge
  }

  operating_system {
    type = "l26"
  }

  serial_device {}  # Enable serial console for qm terminal

  initialization {
    datastore_id = var.proxmox_datastore_vm
    
    ip_config {
      ipv4 {
        address = "10.42.88.120/16"
        gateway = var.gateway
      }
    }

    # No user_account block - user created in cloud-init instead!
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_controller.id
  }

  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }
}

# Worker 1 VM
resource "proxmox_virtual_environment_vm" "worker1" {
  name        = "microk8s-worker1-10.42.88.121"
  description = "MicroK8s Worker Node 1"
  node_name   = var.proxmox_node
  vm_id       = 2121

  agent {
    enabled = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = var.proxmox_datastore_vm
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 32
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge = var.proxmox_bridge
  }

  operating_system {
    type = "l26"
  }

  serial_device {}  # Enable serial console for qm terminal

  initialization {
    datastore_id = var.proxmox_datastore_vm
    
    ip_config {
      ipv4 {
        address = "10.42.88.121/16"
        gateway = var.gateway
      }
    }

    # No user_account block - user created in cloud-init instead!
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_worker1.id
  }

  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }

  depends_on = [proxmox_virtual_environment_vm.controller]
}

# Worker 2 VM
resource "proxmox_virtual_environment_vm" "worker2" {
  name        = "microk8s-worker2-10.42.88.122"
  description = "MicroK8s Worker Node 2"
  node_name   = var.proxmox_node
  vm_id       = 2122

  agent {
    enabled = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = var.proxmox_datastore_vm
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "scsi0"
    size         = 32
    discard      = "on"
    ssd          = true
  }

  network_device {
    bridge = var.proxmox_bridge
  }

  operating_system {
    type = "l26"
  }

  serial_device {}  # Enable serial console for qm terminal

  initialization {
    datastore_id = var.proxmox_datastore_vm
    
    ip_config {
      ipv4 {
        address = "10.42.88.122/16"
        gateway = var.gateway
      }
    }

    # No user_account block - user created in cloud-init instead!
    user_data_file_id = proxmox_virtual_environment_file.cloud_init_worker2.id
  }

  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }

  depends_on = [proxmox_virtual_environment_vm.controller]
}

# ============================================================
# CLOUD-INIT CONFIGURATIONS
# ============================================================

# Cloud-init for prom1
resource "proxmox_virtual_environment_file" "cloud_init_prom1" {
  content_type = "snippets"
  datastore_id = var.proxmox_datastore_snippets
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/cloud-init-worker-minimal-only.yaml", {
      hostname    = "prom1"
      ssh_key     = var.ssh_keys[0]
      vm_password = var.vm_password
    })
    file_name = "cloud-init-prom1.yaml"
  }
}

# Cloud-init for prom2
resource "proxmox_virtual_environment_file" "cloud_init_prom2" {
  content_type = "snippets"
  datastore_id = var.proxmox_datastore_snippets
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/cloud-init-worker-minimal-only.yaml", {
      hostname    = "prom2"
      ssh_key     = var.ssh_keys[0]
      vm_password = var.vm_password
    })
    file_name = "cloud-init-prom2.yaml"
  }
}

# Upload cloud-init config for controller
resource "proxmox_virtual_environment_file" "cloud_init_controller" {
  content_type = "snippets"
  datastore_id = var.proxmox_datastore_snippets
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/cloud-init-controller-minimal-only.yaml", {
      hostname    = "controller"
      ssh_key     = var.ssh_keys[0]
      vm_password = var.vm_password
    })
    file_name = "cloud-init-controller.yaml"
  }
}

# Upload cloud-init config for worker1
resource "proxmox_virtual_environment_file" "cloud_init_worker1" {
  content_type = "snippets"
  datastore_id = var.proxmox_datastore_snippets
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/cloud-init-worker-minimal-only.yaml", {
      hostname    = "worker1"
      ssh_key     = var.ssh_keys[0]
      vm_password = var.vm_password
    })
    file_name = "cloud-init-worker1.yaml"
  }
}

# Upload cloud-init config for worker2
resource "proxmox_virtual_environment_file" "cloud_init_worker2" {
  content_type = "snippets"
  datastore_id = var.proxmox_datastore_snippets
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/cloud-init-worker-minimal-only.yaml", {
      hostname    = "worker2"
      ssh_key     = var.ssh_keys[0]
      vm_password = var.vm_password
    })
    file_name = "cloud-init-worker2.yaml"
  }
}
