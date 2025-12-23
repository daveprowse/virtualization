output "vm_summary" {
  description = "Summary of created VMs"
  value = {
    debserver = {
      hostname = "debserver"
      ip       = "10.0.2.51"
      type     = "Debian 13 Server"
      ssh      = "ssh user@10.0.2.51"
    }
    debclient = {
      hostname = "debclient"
      ip       = "10.0.2.52"
      type     = "Debian 13 Desktop (GNOME)"
      ssh      = "ssh user@10.0.2.52"
    }
    ubuntu_server = {
      hostname = "ubuntu-server"
      ip       = "10.0.2.53"
      type     = "Ubuntu 24.04 Server"
      ssh      = "ssh user@10.0.2.53"
    }
    centos_server = {
      hostname = "centos-server"
      ip       = "10.0.2.61"
      type     = "CentOS Stream 10 Server"
      ssh      = "ssh user@10.0.2.61"
    }
    fedora_client = {
      hostname = "fed-client"
      ip       = "10.0.2.62"
      type     = "Fedora 43 Workstation (GNOME)"
      ssh      = "ssh user@10.0.2.62"
    }
    opensuse_server = {
      hostname = "opensuse"
      ip       = "10.0.2.71"
      type     = "OpenSUSE Leap 16 Server"
      ssh      = "ssh user@10.0.2.71"
    }
  }
}

output "network_info" {
  description = "Network configuration"
  value = {
    network = "NAT (default)"
    subnet  = "10.0.2.0/24"
    gateway = "10.0.2.1"
  }
}
