#!/bin/bash
# Clean up old resources

set -e

echo "Cleaning up old Terraform state and volumes..."
echo ""

# Destroy existing VMs and volumes
if [ -f "terraform.tfstate" ]; then
    echo "Step 1: Destroying existing Terraform resources..."
    terraform destroy -auto-approve
else
    echo "Step 1: No terraform state found, skipping destroy"
fi

echo ""
echo "Step 2: Removing any leftover volumes..."
sudo virsh vol-delete --pool default LNSF-debserver.qcow2 2>/dev/null || true
sudo virsh vol-delete --pool default LNSF-debclient.qcow2 2>/dev/null || true
sudo virsh vol-delete --pool default LNSF-ubuntu-server.qcow2 2>/dev/null || true
sudo virsh vol-delete --pool default LNSF-centos-server.qcow2 2>/dev/null || true
sudo virsh vol-delete --pool default LNSF-fedora-client.qcow2 2>/dev/null || true
sudo virsh vol-delete --pool default LNSF-opensuse-server.qcow2 2>/dev/null || true

echo ""
echo "Step 3: Removing cloud-init ISOs..."
sudo rm -f /var/lib/libvirt/images/LNSF-*-cloudinit.iso

echo ""
echo "Cleanup complete! You can now run ./scripts/deploy.sh"
