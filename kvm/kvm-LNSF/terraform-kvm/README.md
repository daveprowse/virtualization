# KVM Infrastructure with Terraform - Documentation

## Overview
Terraform-based KVM infrastructure deploying 6 VMs on NAT network 10.0.2.0/24.

## Prerequisites
1. **Host System:**
   - KVM/QEMU 8.2.2+ installed and running
   - SSH access configured
   - Host: nw2 (10.42.0.240)
   - User: dpro

2. **Install Required Tools:**
   ```bash
   # On host machine (nw2)
   sudo apt update
   sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils genisoimage
   
   # On machine running Terraform
   # Install Terraform
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   
   # Install genisoimage (required for cloud-init ISO creation)
   # Debian/Ubuntu:
   sudo apt install -y genisoimage
   # RHEL/CentOS/Fedora:
   # sudo dnf install -y genisoimage
   # Arch:
   # sudo pacman -S cdrtools
   
   # Install Ansible (optional, for post-configuration)
   sudo apt install -y ansible
   ```

3. **SSH Key Setup:**
   - Generate SSH key if not exists: `ssh-keygen -t rsa -b 4096`
   - Copy public key: `cat ~/.ssh/id_rsa.pub`

## Quick Start

### 1. Configure Variables
```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

### 2. Generate Password Hashes
```bash
# Run password hash generator
./scripts/generate_password_hash.sh

# Add hashes to terraform.tfvars
```

### 3. Deploy Infrastructure
```bash
./scripts/deploy.sh
```

### 4. Access VMs
```bash
# SSH as user
ssh user@10.0.2.51

# SSH as root
ssh root@10.0.2.51
```

## VM Details

| VM | Hostname | IP | vCPUs | RAM | OS | Type |
|---|---|---|---|---|---|---|
| Debian Server | debserver | 10.0.2.51 | 2 | 4GB | Debian 13 | Server |
| Debian Client | debclient | 10.0.2.52 | 4 | 8GB | Debian 13 | Desktop (GNOME) |
| Ubuntu Server | ubuntu-server | 10.0.2.53 | 2 | 4GB | Ubuntu 24.04 | Server |
| CentOS Server | centos-server | 10.0.2.61 | 2 | 4GB | CentOS Stream 10 | Server |
| Fedora Client | fed-client | 10.0.2.62 | 4 | 8GB | Fedora 43 | Desktop (GNOME) |
| OpenSUSE Server | opensuse | 10.0.2.71 | 2 | 4GB | OpenSUSE Leap 16 | Server |

## Server Configurations

### Debian Server (10.0.2.51)
- Root + user account
- VIM (default editor), TMUX, SSH
- Console: TerminusBold 16x32
- Resolution: 1920x1080

### Ubuntu Server (10.0.2.53)
- User account (sudo enabled)
- VIM (default editor), TMUX, SSH
- Console: TerminusBold 10x20
- Resolution: 1920x1080

### CentOS Server (10.0.2.61)
- User account (sudo enabled)
- VIM (default editor), TMUX, SSH
- Console: ter-v24b
- Resolution: 1920x1080

### OpenSUSE Server (10.0.2.71)
- User account (sudo enabled)
- VIM (default editor), TMUX, SSH
- Console: ter-v24b
- Resolution: 1920x1080

## Desktop Configurations

### Debian Client (10.0.2.52)
- GNOME Desktop
- User account (sudo enabled), SSH
- VIM, Tilix, TMUX
- VS Code, NoMachine
- Resolution: 1920x1080, 150% scaling
- Terminal: Monospace 13, Light theme
- Keyboard: Ctrl+Alt+T for terminal

### Fedora Client (10.0.2.62)
- GNOME Desktop
- User account (sudo enabled), SSH
- VIM, Tilix, TMUX
- VS Code, NoMachine
- Resolution: 1920x1080, 150% scaling
- Terminal: Monospace 13, Dark theme
- Keyboard: Ctrl+Alt+T for terminal

## Manual Operations

### Deploy Individual VM
```bash
terraform apply -target=libvirt_domain.debserver
```

### View Infrastructure
```bash
terraform show
```

### Update Configuration
```bash
# Modify main.tf or cloud-init files
terraform plan
terraform apply
```

### Destroy Infrastructure
```bash
./scripts/destroy.sh
# OR
terraform destroy
```

### Destroy Single VM
```bash
terraform destroy -target=libvirt_domain.debserver
```

## Troubleshooting

### VM Not Starting
1. Check host connectivity: `ssh dpro@10.42.0.240`
2. Verify libvirt: `virsh list --all`
3. Check logs: `terraform show`

### SSH Connection Failed
1. Wait for cloud-init (2-5 minutes after creation)
2. Verify IP: `virsh domifaddr <vm-name>`
3. Check SSH key in terraform.tfvars

### Password Not Working
1. Verify hash format in terraform.tfvars
2. Regenerate using: `./scripts/generate_password_hash.sh`
3. Run `terraform apply` to update

### Desktop Not Displaying
1. Connect via virt-viewer: `virt-viewer -c qemu+ssh://dpro@10.42.0.240/system <vm-name>`
2. Wait for full boot (desktop VMs take longer)
3. Check cloud-init status: `cloud-init status`

## File Structure
```
terraform-kvm/
├── main.tf                  # Main Terraform configuration
├── variables.tf             # Variable definitions
├── terraform.tfvars.example # Example variables file
├── cloud-init/             # Cloud-init templates
│   ├── network-static.yml
│   ├── debian-server.yml
│   ├── debian-client.yml
│   ├── ubuntu-server.yml
│   ├── centos-server.yml
│   ├── fedora-client.yml
│   └── opensuse-server.yml
├── ansible/                # Ansible configuration
│   ├── inventory.ini
│   └── configure.yml
└── scripts/                # Helper scripts
    ├── deploy.sh
    ├── destroy.sh
    └── generate_password_hash.sh
```

## Important Notes

1. **Passwords:** Must be hashed (SHA-512) in terraform.tfvars
2. **SSH Key:** Use full public key content in terraform.tfvars
3. **Network:** VMs use existing NAT network 10.0.2.0/24
4. **Boot Time:** Servers: 2-3 min, Desktops: 5-10 min
5. **Storage:** Base images stored in /home/dpro/VMs
6. **Cloud Images:** Downloaded automatically on first run

## Testing Checklist

After deployment, verify:
- [ ] All VMs pingable
- [ ] SSH access works (user and root)
- [ ] Passwords work
- [ ] Desktop VMs show GUI
- [ ] VIM is default editor
- [ ] TMUX installed
- [ ] VS Code on desktops
- [ ] Terminal fonts correct
- [ ] Keyboard shortcuts work (desktops)

## Advanced Configuration

### Modify VM Resources
Edit main.tf:
```hcl
resource "libvirt_domain" "debserver" {
  memory = 8192  # Change RAM
  vcpu   = 4     # Change CPUs
  ...
}
```

### Add New VM
1. Add base volume in main.tf
2. Create cloud-init template
3. Add domain resource
4. Run `terraform apply`

### Change Network
Edit cloud-init/network-static.yml to modify network configuration.

## Support
Report issues or questions via project repository.
