#!/bin/bash
# Create custom libvirt storage pool for user-downloaded images
# Using qemu:///session (runs as your user, not root)

set -e

POOL_NAME="user-images"
POOL_PATH="$HOME/kvm-images"

# Create directory if it doesn't exist
mkdir -p "$POOL_PATH"

echo "Setting up custom storage pool: $POOL_NAME"
echo "Location: $POOL_PATH"
echo "Mode: qemu:///session (user-mode, no root)"
echo ""

# Check if pool already exists (session mode, no sudo)
if virsh -c qemu:///session pool-list --all 2>/dev/null | grep -q "$POOL_NAME"; then
    echo "Pool '$POOL_NAME' already exists"
    
    # Make sure it's started and set to autostart
    virsh -c qemu:///session pool-start "$POOL_NAME" 2>/dev/null || echo "Pool already active"
    virsh -c qemu:///session pool-autostart "$POOL_NAME" 2>/dev/null || true
else
    # Define the pool (no sudo needed in session mode)
    echo "Creating pool..."
    virsh -c qemu:///session pool-define-as "$POOL_NAME" dir --target "$POOL_PATH"
    
    # Build the pool
    virsh -c qemu:///session pool-build "$POOL_NAME"
    
    # Start the pool
    virsh -c qemu:///session pool-start "$POOL_NAME"
    
    # Set to autostart
    virsh -c qemu:///session pool-autostart "$POOL_NAME"
    
    echo "Pool '$POOL_NAME' created successfully!"
fi

echo ""
echo "Pool information:"
virsh -c qemu:///session pool-info "$POOL_NAME"

echo ""
echo "✓ Storage pool setup complete!"
echo ""
echo "Note: Using qemu:///session - all operations run as your user (dpro)"
