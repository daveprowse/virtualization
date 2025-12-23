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
echo "Step 2: Creating home directory storage pool..."
"$SCRIPT_DIR/create-home-pool.sh"

echo ""
echo "Step 3: Initializing Terraform..."
terraform init

echo ""
echo "Step 4: Applying infrastructure..."
terraform apply -auto-approve

echo ""
echo "Deployment completed successfully!"
echo ""

if [ -z "$SKIP_ANSIBLE" ]; then
    echo "Step 5: Waiting for VMs to be fully booted (60 seconds)..."
    sleep 60
    
    echo ""
    echo "Step 6: Running Ansible post-configuration..."
    cd ansible
    ansible-playbook -i inventory.ini configure.yml
    cd ..
    
    echo ""
    echo "Post-configuration completed!"
else
    echo "Step 5: Skipping Ansible configuration (not installed)"
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
