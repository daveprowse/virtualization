#!/bin/bash
# Fix permissions on volumes after Terraform creates them
# Run this after: terraform apply -target=libvirt_volume.*

set -e

echo "Fixing permissions on Terraform-created volumes..."
echo ""

# Wait a moment for all volumes to be created
sleep 2

# Fix permissions on all LNSF volumes
echo "Changing ownership to libvirt-qemu:kvm..."
sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/LNSF-*.qcow2 2>/dev/null || echo "No qcow2 files found"

echo "Setting permissions to 660..."
sudo chmod 660 /var/lib/libvirt/images/LNSF-*.qcow2 2>/dev/null || echo "No qcow2 files found"

echo ""
echo "✓ Permissions fixed!"
echo ""
echo "Volume ownership:"
ls -la /var/lib/libvirt/images/LNSF-*.qcow2 2>/dev/null || echo "No volumes found"

echo ""
echo "Now run: terraform apply"
echo "(This will create the VMs)"
