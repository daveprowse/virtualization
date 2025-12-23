# Changes for v0.9.1

## Provider Version Update
- Updated from `dmacvicar/libvirt ~> 0.7` to `~> 0.9.1`

## VM Naming Changes
All VMs now have "LNSF-" prefix in KVM (libvirt domain names):
- `debserver` → `LNSF-debserver`
- `debclient` → `LNSF-debclient`
- `ubuntu-server` → `LNSF-ubuntu-server`
- `centos-server` → `LNSF-centos-server`
- `fed-client` → `LNSF-fed-client`
- `opensuse` → `LNSF-opensuse`

Note: Hostnames remain unchanged (e.g., hostname is still "debserver")

## Schema Changes for v0.9.1

### Base Volume Creation
**Old (v0.7):**
```hcl
resource "libvirt_volume" "debian13_base" {
  name   = "debian-13-base.qcow2"
  pool   = "default"
  source = "http://..."
  format = "qcow2"
}
```

**New (v0.9.1):**
```hcl
resource "libvirt_volume" "debian13_base" {
  name   = "debian-13-base.qcow2"
  pool   = "default"
  format = "qcow2"
  create = {
    content = {
      url = "http://..."
    }
  }
}
```

### Derived Volumes with Backing Store
**Old (v0.7):**
```hcl
resource "libvirt_volume" "debserver" {
  name           = "debserver.qcow2"
  base_volume_id = libvirt_volume.debian13_base.id
  pool           = "default"
  size           = 32212254720
}
```

**New (v0.9.1):**
```hcl
resource "libvirt_volume" "debserver" {
  name     = "LNSF-debserver.qcow2"
  pool     = "default"
  format   = "qcow2"
  capacity = 32212254720
  backing_store = {
    path   = libvirt_volume.debian13_base.path
    format = "qcow2"
  }
}
```

### Cloud-init Changes
**Old (v0.7):**
```hcl
resource "libvirt_cloudinit_disk" "debserver" {
  name           = "debserver-cloudinit.iso"
  user_data      = templatefile(...)
  network_config = templatefile(...)
}
```

**New (v0.9.1):**
```hcl
resource "libvirt_cloudinit_disk" "debserver" {
  name = "LNSF-debserver-cloudinit"
  user_data = templatefile(...)
  meta_data = yamlencode({
    instance-id    = "debserver-001"
    local-hostname = "debserver"
  })
  network_config = templatefile(...)
}

# Additional volume resource to upload cloudinit ISO
resource "libvirt_volume" "debserver_cloudinit" {
  name = "LNSF-debserver-cloudinit.iso"
  pool = "default"
  create = {
    content = {
      url = libvirt_cloudinit_disk.debserver.path
    }
  }
}
```

### Domain Configuration
**Old (v0.7):**
```hcl
resource "libvirt_domain" "debserver" {
  name      = "debserver"
  memory    = 4096
  vcpu      = 2
  cloudinit = libvirt_cloudinit_disk.debserver.id

  disk {
    volume_id = libvirt_volume.debserver.id
  }

  network_interface {
    network_name   = "default"
    addresses      = ["10.0.2.51"]
    wait_for_lease = false
  }

  graphics {
    type        = "spice"
    listen_type = "address"
  }

  video {
    type = "qxl"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
```

**New (v0.9.1):**
```hcl
resource "libvirt_domain" "debserver" {
  name        = "LNSF-debserver"
  type        = "kvm"
  memory      = 4096
  memory_unit = "MiB"
  vcpu        = 2

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
  }

  devices = {
    disks = [
      {
        source = {
          pool   = libvirt_volume.debserver.pool
          volume = libvirt_volume.debserver.name
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      },
      {
        device = "cdrom"
        source = {
          pool   = libvirt_volume.debserver_cloudinit.pool
          volume = libvirt_volume.debserver_cloudinit.name
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
      }
    ]
    interfaces = [
      {
        source = {
          network = "default"
        }
        model = {
          type = "virtio"
        }
      }
    ]
    graphics = [
      {
        type = "spice"
        listen = {
          type = "address"
        }
      }
    ]
    videos = [
      {
        model = {
          type = "qxl"
        }
      }
    ]
    consoles = [
      {
        type = "pty"
        target = {
          type = "serial"
          port = 0
        }
      }
    ]
  }
}
```

## Key Differences Summary

1. **type attribute**: Required on domain resources (set to "kvm")
2. **memory_unit**: Now explicitly specified as "MiB"
3. **os block**: More detailed OS configuration
4. **devices block**: All device types now nested under single `devices` attribute
5. **Arrays for devices**: disks, interfaces, graphics, videos, consoles are now lists
6. **Cloud-init**: Requires explicit meta_data and separate volume resource
7. **size → capacity**: Volume size attribute renamed
8. **base_volume_id → backing_store**: New nested structure with path and format
9. **source → create.content.url**: Base volumes use nested structure for downloads
