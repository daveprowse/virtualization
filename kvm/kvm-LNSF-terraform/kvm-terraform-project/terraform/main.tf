terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Compute display names with version numbers
locals {
  debserver_name       = var.debserver_display_name != "" ? var.debserver_display_name : "LNSF-Debian-Server-${var.debian_version}"
  debclient_name       = var.debclient_display_name != "" ? var.debclient_display_name : "LNSF-Debian-Client-${var.debian_version}"
  ubuntu_server_name   = var.ubuntu_server_display_name != "" ? var.ubuntu_server_display_name : "LNSF-Ubuntu-Server-${var.ubuntu_version}"
  centos_server_name   = var.centos_server_display_name != "" ? var.centos_server_display_name : "LNSF-CentOS-${var.centos_version}"
  fedora_client_name   = var.fedora_client_display_name != "" ? var.fedora_client_display_name : "LNSF-Fedora-${var.fedora_version}"
  opensuse_name        = var.opensuse_display_name != "" ? var.opensuse_display_name : "LNSF-OpenSUSE-${var.opensuse_version}"
}

# Storage pool
resource "libvirt_pool" "kvm_images" {
  name = "KVM-IMAGES"
  type = "dir"
  target {
    path = var.kvm_images_dir
  }
}

# Base image volumes
resource "libvirt_volume" "debian_base" {
  name   = "debian-base.qcow2"
  pool   = libvirt_pool.kvm_images.name
  source = "file://${var.kvm_images_dir}/${var.debian_image_name}"
  format = "qcow2"
}

resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-base.qcow2"
  pool   = libvirt_pool.kvm_images.name
  source = "file://${var.kvm_images_dir}/${var.ubuntu_image_name}"
  format = "qcow2"
}

resource "libvirt_volume" "centos_base" {
  name   = "centos-base.qcow2"
  pool   = libvirt_pool.kvm_images.name
  source = "file://${var.kvm_images_dir}/${var.centos_image_name}"
  format = "qcow2"
}

resource "libvirt_volume" "fedora_base" {
  name   = "fedora-base.qcow2"
  pool   = libvirt_pool.kvm_images.name
  source = "file://${var.kvm_images_dir}/${var.fedora_image_name}"
  format = "qcow2"
}

resource "libvirt_volume" "opensuse_base" {
  name   = "opensuse-base.qcow2"
  pool   = libvirt_pool.kvm_images.name
  source = "file://${var.kvm_images_dir}/${var.opensuse_image_name}"
  format = "qcow2"
}

# VM volumes (copy-on-write from base images)
resource "libvirt_volume" "debserver_disk" {
  name           = "debserver.qcow2"
  pool           = libvirt_pool.kvm_images.name
  base_volume_id = libvirt_volume.debian_base.id
  size           = 32212254720
}

resource "libvirt_volume" "debclient_disk" {
  name           = "debclient.qcow2"
  pool           = libvirt_pool.kvm_images.name
  base_volume_id = libvirt_volume.debian_base.id
  size           = 42949672960
}

resource "libvirt_volume" "ubuntu_disk" {
  name           = "ubuntu-server.qcow2"
  pool           = libvirt_pool.kvm_images.name
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = 32212254720
}

resource "libvirt_volume" "centos_disk" {
  name           = "centos-server.qcow2"
  pool           = libvirt_pool.kvm_images.name
  base_volume_id = libvirt_volume.centos_base.id
  size           = 32212254720
}

resource "libvirt_volume" "fedora_disk" {
  name           = "fedora-client.qcow2"
  pool           = libvirt_pool.kvm_images.name
  base_volume_id = libvirt_volume.fedora_base.id
  size           = 42949672960
}

resource "libvirt_volume" "opensuse_disk" {
  name           = "opensuse.qcow2"
  pool           = libvirt_pool.kvm_images.name
  base_volume_id = libvirt_volume.opensuse_base.id
  size           = 32212254720
}

# Cloud-init disks
resource "libvirt_cloudinit_disk" "debserver" {
  name      = "debserver-cloudinit.iso"
  pool      = libvirt_pool.kvm_images.name
  user_data = templatefile("${path.module}/../cloud-init/debserver-user-data.yaml", {
    hostname      = var.debserver_hostname
    root_password = var.root_password
    user_password = var.user_password
    ssh_key       = var.ssh_public_key
  })
  meta_data = <<-EOF
    instance-id: ${var.debserver_hostname}
    local-hostname: ${var.debserver_hostname}
  EOF
}

resource "libvirt_cloudinit_disk" "debclient" {
  name      = "debclient-cloudinit.iso"
  pool      = libvirt_pool.kvm_images.name
  user_data = templatefile("${path.module}/../cloud-init/debclient-user-data.yaml", {
    hostname      = var.debclient_hostname
    root_password = var.root_password
    user_password = var.user_password
    ssh_key       = var.ssh_public_key
  })
  meta_data = <<-EOF
    instance-id: ${var.debclient_hostname}
    local-hostname: ${var.debclient_hostname}
  EOF
}

resource "libvirt_cloudinit_disk" "ubuntu_server" {
  name      = "ubuntu-server-cloudinit.iso"
  pool      = libvirt_pool.kvm_images.name
  user_data = templatefile("${path.module}/../cloud-init/ubuntu-server-user-data.yaml", {
    hostname      = var.ubuntu_server_hostname
    root_password = var.root_password
    user_password = var.user_password
    ssh_key       = var.ssh_public_key
  })
  meta_data = <<-EOF
    instance-id: ${var.ubuntu_server_hostname}
    local-hostname: ${var.ubuntu_server_hostname}
  EOF
}

resource "libvirt_cloudinit_disk" "centos_server" {
  name      = "centos-server-cloudinit.iso"
  pool      = libvirt_pool.kvm_images.name
  user_data = templatefile("${path.module}/../cloud-init/centos-server-user-data.yaml", {
    hostname      = var.centos_server_hostname
    root_password = var.root_password
    user_password = var.user_password
    ssh_key       = var.ssh_public_key
  })
  meta_data = <<-EOF
    instance-id: ${var.centos_server_hostname}
    local-hostname: ${var.centos_server_hostname}
  EOF
}

resource "libvirt_cloudinit_disk" "fedora_client" {
  name      = "fedora-client-cloudinit.iso"
  pool      = libvirt_pool.kvm_images.name
  user_data = templatefile("${path.module}/../cloud-init/fedora-client-user-data.yaml", {
    hostname      = var.fedora_client_hostname
    root_password = var.root_password
    user_password = var.user_password
    ssh_key       = var.ssh_public_key
  })
  meta_data = <<-EOF
    instance-id: ${var.fedora_client_hostname}
    local-hostname: ${var.fedora_client_hostname}
  EOF
}

resource "libvirt_cloudinit_disk" "opensuse" {
  name      = "opensuse-cloudinit.iso"
  pool      = libvirt_pool.kvm_images.name
  user_data = templatefile("${path.module}/../cloud-init/opensuse-user-data.yaml", {
    hostname      = var.opensuse_hostname
    root_password = var.root_password
    user_password = var.user_password
    ssh_key       = var.ssh_public_key
  })
  meta_data = <<-EOF
    instance-id: ${var.opensuse_hostname}
    local-hostname: ${var.opensuse_hostname}
  EOF
}

# Debian Server VM
resource "libvirt_domain" "debserver" {
  name   = local.debserver_name
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.debserver.id

  network_interface {
    network_name = var.network_name
    addresses    = [var.debserver_ip]
  }

  disk {
    volume_id = libvirt_volume.debserver_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# Debian Client VM
resource "libvirt_domain" "debclient" {
  name   = local.debclient_name
  memory = "8192"
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.debclient.id

  network_interface {
    network_name = var.network_name
    addresses    = [var.debclient_ip]
  }

  disk {
    volume_id = libvirt_volume.debclient_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# Ubuntu Server VM
resource "libvirt_domain" "ubuntu_server" {
  name   = local.ubuntu_server_name
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.ubuntu_server.id

  network_interface {
    network_name = var.network_name
    addresses    = [var.ubuntu_server_ip]
  }

  disk {
    volume_id = libvirt_volume.ubuntu_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# CentOS Server VM
resource "libvirt_domain" "centos_server" {
  name   = local.centos_server_name
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.centos_server.id

  network_interface {
    network_name = var.network_name
    addresses    = [var.centos_server_ip]
  }

  disk {
    volume_id = libvirt_volume.centos_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# Fedora Client VM
resource "libvirt_domain" "fedora_client" {
  name   = local.fedora_client_name
  memory = "8192"
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.fedora_client.id

  network_interface {
    network_name = var.network_name
    addresses    = [var.fedora_client_ip]
  }

  disk {
    volume_id = libvirt_volume.fedora_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

# OpenSUSE VM
resource "libvirt_domain" "opensuse" {
  name   = local.opensuse_name
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.opensuse.id

  network_interface {
    network_name = var.network_name
    addresses    = [var.opensuse_ip]
  }

  disk {
    volume_id = libvirt_volume.opensuse_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
