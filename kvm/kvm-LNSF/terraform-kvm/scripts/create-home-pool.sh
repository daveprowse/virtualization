#!/bin/bash
# Create or update libvirt pool in home directory (system mode)

set -e

POOL_NAME="user-images"
POOL_PATH="$HOME/kvm-images"

mkdir -p "$POOL_PATH"

echo "Setting up libvirt pool in home directory..."
echo "Pool: $POOL_NAME"
echo "Path: $POOL_PATH"
echo ""

# Check if pool exists
if sudo virsh pool-info $POOL_NAME &>/dev/null; then
    echo "Pool '$POOL_NAME' already exists, ensuring it's active..."
    sudo virsh pool-start $POOL_NAME 2>/dev/null || echo "  (already active)"
    sudo virsh pool-autostart $POOL_NAME 2>/dev/null || true
else
    echo "Creating new pool..."
    sudo virsh pool-define-as $POOL_NAME dir --target "$POOL_PATH"
    sudo virsh pool-build $POOL_NAME
    sudo virsh pool-start $POOL_NAME
    sudo virsh pool-autostart $POOL_NAME
fi

# Update AppArmor to allow access to home directory
echo ""
echo "Updating AppArmor profile for libvirt..."
sudo mkdir -p /etc/apparmor.d/local/abstractions
sudo touch /etc/apparmor.d/local/abstractions/libvirt-qemu

if ! grep -q "$POOL_PATH" /etc/apparmor.d/local/abstractions/libvirt-qemu 2>/dev/null; then
    sudo tee -a /etc/apparmor.d/local/abstractions/libvirt-qemu > /dev/null << APPARMOR
# Allow access to user home directory for VM images
$POOL_PATH/** rwk,
APPARMOR
    echo "  Added AppArmor rule"
else
    echo "  AppArmor rule already exists"
fi

sudo systemctl reload apparmor
sudo systemctl restart libvirtd

echo ""
echo "✓ Pool ready!"
sudo virsh pool-info $POOL_NAME
