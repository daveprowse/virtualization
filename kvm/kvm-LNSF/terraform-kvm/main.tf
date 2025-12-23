terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Debian Server
resource "libvirt_volume" "debserver" {
  name   = "LNSF-debserver.qcow2"
  pool   = "default"
  source = pathexpand("~/kvm-images/debian-13-generic-amd64.qcow2")
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "debserver" {
  name = "LNSF-debserver-cloudinit.iso"
  pool = "default"
  user_data = templatefile("${path.module}/cloud-init/debian-server.yml", {
    hostname      = "debserver"
    root_password = var.root_password
    user_password = var.user_password
    ssh_key       = var.ssh_public_key
  })
  meta_data = templatefile("${path.module}/cloud-init/network-static.yml", {
    ip_address = "10.0.2.51"
  })
}

resource "libvirt_domain" "debserver" {
  
  name   = "LNSF-debserver"
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.debserver.id

  disk {
    volume_id = libvirt_volume.debserver.id
  }

  network_interface {
    network_name = "default"
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

# Debian Client
resource "libvirt_volume" "debclient" {
  name   = "LNSF-debclient.qcow2"
  pool   = "default"
  source = pathexpand("~/kvm-images/debian-13-generic-amd64.qcow2")
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "debclient" {
  name = "LNSF-debclient-cloudinit.iso"
  pool = "default"
  user_data = templatefile("${path.module}/cloud-init/debian-client.yml", {
    hostname      = "debclient"
    root_password = var.root_password
    user_password = var.user_password
    ssh_key       = var.ssh_public_key
  })
  meta_data = templatefile("${path.module}/cloud-init/network-static.yml", {
    ip_address = "10.0.2.52"
  })
}

resource "libvirt_domain" "debclient" {

  name   = "LNSF-debclient"
  memory = "8192"
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.debclient.id

  disk {
    volume_id = libvirt_volume.debclient.id
  }

  network_interface {
    network_name = "default"
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

# Ubuntu Server
resource "libvirt_volume" "ubuntu_server" {
  name   = "LNSF-ubuntu-server.qcow2"
  pool   = "default"
  source = pathexpand("~/kvm-images/ubuntu-24.04-server-cloudimg-amd64.img")
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "ubuntu_server" {
  name = "LNSF-ubuntu-server-cloudinit.iso"
  pool = "default"
  user_data = templatefile("${path.module}/cloud-init/ubuntu-server.yml", {
    hostname      = "ubuntu-server"
    root_password = var.root_password
    user_password = var.user_password
    ssh_key       = var.ssh_public_key
  })
  meta_data = templatefile("${path.module}/cloud-init/network-static.yml", {
    ip_address = "10.0.2.53"
  })
}

resource "libvirt_domain" "ubuntu_server" {

  name   = "LNSF-ubuntu-server"
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.ubuntu_server.id

  disk {
    volume_id = libvirt_volume.ubuntu_server.id
  }

  network_interface {
    network_name = "default"
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

# CentOS Server
resource "libvirt_volume" "centos_server" {
  name   = "LNSF-centos-server.qcow2"
  pool   = "default"
  source = pathexpand("~/kvm-images/centos-stream-10-genericcloud.qcow2")
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "centos_server" {
  name = "LNSF-centos-server-cloudinit.iso"
  pool = "default"
  user_data = templatefile("${path.module}/cloud-init/centos-server.yml", {
    hostname      = "centos-server"
    root_password = var.root_password
    user_password = var.user_password
    ssh_key       = var.ssh_public_key
  })
  meta_data = templatefile("${path.module}/cloud-init/network-static.yml", {
    ip_address = "10.0.2.61"
  })
}

resource "libvirt_domain" "centos_server" {

  name   = "LNSF-centos-server"
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.centos_server.id

  disk {
    volume_id = libvirt_volume.centos_server.id
  }

  network_interface {
    network_name = "default"
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

# Fedora Client
resource "libvirt_volume" "fedora_client" {
  name   = "LNSF-fedora-client.qcow2"
  pool   = "default"
  source = pathexpand("~/kvm-images/fedora-41-cloud-base.qcow2")
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "fedora_client" {
  name = "LNSF-fedora-client-cloudinit.iso"
  pool = "default"
  user_data = templatefile("${path.module}/cloud-init/fedora-client.yml", {
    hostname      = "fed-client"
    root_password = var.root_password
    user_password = var.user_password
    ssh_key       = var.ssh_public_key
  })
  meta_data = templatefile("${path.module}/cloud-init/network-static.yml", {
    ip_address = "10.0.2.62"
  })
}

resource "libvirt_domain" "fedora_client" {

  name   = "LNSF-fed-client"
  memory = "8192"
  vcpu   = 4

  cloudinit = libvirt_cloudinit_disk.fedora_client.id

  disk {
    volume_id = libvirt_volume.fedora_client.id
  }

  network_interface {
    network_name = "default"
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

# OpenSUSE Server
resource "libvirt_volume" "opensuse_server" {
  name   = "LNSF-opensuse-server.qcow2"
  pool   = "default"
  source = pathexpand("~/kvm-images/opensuse-leap-15.6-nocloud.qcow2")
  format = "qcow2"
}

resource "libvirt_cloudinit_disk" "opensuse_server" {
  name = "LNSF-opensuse-server-cloudinit.iso"
  pool = "default"
  user_data = templatefile("${path.module}/cloud-init/opensuse-server.yml", {
    hostname      = "opensuse"
    root_password = var.root_password
    user_password = var.user_password
    ssh_key       = var.ssh_public_key
  })
  meta_data = templatefile("${path.module}/cloud-init/network-static.yml", {
    ip_address = "10.0.2.71"
  })
}

resource "libvirt_domain" "opensuse_server" {

  name   = "LNSF-opensuse"
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.opensuse_server.id

  disk {
    volume_id = libvirt_volume.opensuse_server.id
  }

  network_interface {
    network_name = "default"
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
