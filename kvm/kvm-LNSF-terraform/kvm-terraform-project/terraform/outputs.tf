output "vm_summary" {
  description = "Summary of all VMs"
  value = {
    debserver = {
      name = libvirt_domain.debserver.name
      ip   = var.debserver_ip
    }
    debclient = {
      name = libvirt_domain.debclient.name
      ip   = var.debclient_ip
    }
    ubuntu_server = {
      name = libvirt_domain.ubuntu_server.name
      ip   = var.ubuntu_server_ip
    }
    centos_server = {
      name = libvirt_domain.centos_server.name
      ip   = var.centos_server_ip
    }
    fedora_client = {
      name = libvirt_domain.fedora_client.name
      ip   = var.fedora_client_ip
    }
    opensuse = {
      name = libvirt_domain.opensuse.name
      ip   = var.opensuse_ip
    }
  }
}

output "debserver_ip" {
  value = var.debserver_ip
}

output "debclient_ip" {
  value = var.debclient_ip
}

output "ubuntu_server_ip" {
  value = var.ubuntu_server_ip
}

output "centos_server_ip" {
  value = var.centos_server_ip
}

output "fedora_client_ip" {
  value = var.fedora_client_ip
}

output "opensuse_ip" {
  value = var.opensuse_ip
}
