#!/bin/bash
# Main deployment script for KVM infrastructure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo "=========================================="
echo "KVM Infrastructure Deployment"
echo "=========================================="
echo ""

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "ERROR: terraform.tfvars not found!"
    echo "Please copy terraform.tfvars.example to terraform.tfvars and configure it"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "ERROR: Terraform is not installed"
    exit 1
fi

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "WARNING: Ansible is not installed. Post-configuration will be skipped."
    SKIP_ANSIBLE=1
fi

echo "Step 1: Downloading cloud images..."
"$SCRIPT_DIR/download-images.sh"

echo ""
echo "Step 2: Initializing Terraform..."
terraform init

echo ""
echo "Step 3: Creating volumes first (will be root-owned)..."
terraform apply -target=libvirt_volume.debserver \
                -target=libvirt_volume.debclient \
                -target=libvirt_volume.ubuntu_server \
                -target=libvirt_volume.centos_server \
                -target=libvirt_volume.fedora_client \
                -target=libvirt_volume.opensuse_server \
                -auto-approve

echo ""
echo "Step 4: Fixing volume permissions..."
"$SCRIPT_DIR/fix-volume-permissions.sh"

echo ""
echo "Step 5: Creating VMs and cloud-init resources..."
terraform apply -auto-approve

echo ""
echo "Deployment completed successfully!"
echo ""

if [ -z "$SKIP_ANSIBLE" ]; then
    echo "Step 6: Waiting for VMs to be fully booted (60 seconds)..."
    sleep 60
    
    echo ""
    echo "Step 7: Running Ansible post-configuration..."
    cd ansible
    ansible-playbook -i inventory.ini configure.yml
    cd ..
    
    echo ""
    echo "Post-configuration completed!"
else
    echo "Step 6: Skipping Ansible configuration (not installed)"
fi

echo ""
echo "=========================================="
echo "Deployment Summary"
echo "=========================================="
echo "VMs created:"
echo "  - debserver (10.0.2.51) - Debian 13 Server"
echo "  - debclient (10.0.2.52) - Debian 13 Client with GNOME"
echo "  - ubuntu-server (10.0.2.53) - Ubuntu 24.04 Server"
echo "  - centos-server (10.0.2.61) - CentOS Stream 10 Server"
echo "  - fed-client (10.0.2.62) - Fedora 43 Workstation"
echo "  - opensuse (10.0.2.71) - OpenSUSE Leap 16 Server"
echo ""
echo "You can SSH into any VM using:"
echo "  ssh user@<IP_ADDRESS>"
echo ""
echo "Or as root:"
echo "  ssh root@<IP_ADDRESS>"
echo "=========================================="
