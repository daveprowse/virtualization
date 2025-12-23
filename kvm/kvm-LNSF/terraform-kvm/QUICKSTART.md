# Quick Start Guide

## Step 1: Prerequisites
```bash
# Install genisoimage (required for cloud-init)
# Debian/Ubuntu:
sudo apt install -y genisoimage
# RHEL/CentOS/Fedora:
# sudo dnf install -y genisoimage

# Verify Terraform installed
terraform version

# Verify SSH access to KVM host
ssh dpro@10.42.0.240
```

## Step 2: Configure
```bash
# Copy and edit configuration
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Required in `terraform.tfvars`:
- `ssh_public_key` - Your SSH public key (from `~/.ssh/id_rsa.pub`)
- `root_password` - Hashed password (use `make hash` to generate)
- `*_user_password` - Hashed passwords for each VM's user account

## Step 3: Generate Password Hashes
```bash
make hash
# OR
./scripts/generate_password_hash.sh
```

Copy the hashes to `terraform.tfvars`

## Step 4: Deploy
```bash
make deploy
# OR
./scripts/deploy.sh
```

Wait 5-10 minutes for deployment and configuration.

## Step 5: Access VMs
```bash
# SSH as user
ssh user@10.0.2.51  # Debian server
ssh user@10.0.2.52  # Debian client
ssh user@10.0.2.53  # Ubuntu server
ssh user@10.0.2.61  # CentOS server
ssh user@10.0.2.62  # Fedora client
ssh user@10.0.2.71  # OpenSUSE server

# SSH as root
ssh root@10.0.2.51
```

## Step 6: Verify
```bash
# Check all VMs
for ip in 51 52 53 61 62 71; do
  echo "Testing 10.0.2.$ip..."
  ping -c 1 10.0.2.$ip
done

# Test SSH
ssh user@10.0.2.51 'hostname && whoami'
```

## Troubleshooting

### Cannot connect via SSH
Wait 3-5 minutes after deployment for cloud-init to complete.

### Password doesn't work
Ensure password is properly hashed in terraform.tfvars

### VM not responding
Check VM status:
```bash
ssh dpro@10.42.0.240 'virsh list --all'
```

## Common Commands

```bash
make help      # Show available commands
make init      # Initialize Terraform
make plan      # Preview changes
make deploy    # Deploy infrastructure
make destroy   # Destroy infrastructure
make clean     # Clean Terraform files
make hash      # Generate password hash
```

## Next Steps

See full documentation in `README.md`
