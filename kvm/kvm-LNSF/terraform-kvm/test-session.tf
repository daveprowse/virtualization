terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///session"
}

resource "libvirt_volume" "test" {
  name   = "test-volume.qcow2"
  pool   = "default"
  size   = 1073741824  # 1GB
  format = "qcow2"
}

output "volume_path" {
  value = libvirt_volume.test.id
}
