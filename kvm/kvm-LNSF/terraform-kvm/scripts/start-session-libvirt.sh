#!/bin/bash
# Verify and setup session libvirt (auto-starts on connection)

set -e

echo "Verifying session libvirt..."
echo ""

# Test connection - this will auto-start session daemon if needed
echo "Testing connection to qemu:///session..."
virsh -c qemu:///session uri

echo ""
echo "✓ Session mode is available"
echo ""

echo "Creating default session pool if needed..."
DEFAULT_POOL_PATH="$HOME/.local/share/libvirt/images"
mkdir -p "$DEFAULT_POOL_PATH"

# Check if default pool exists in session
if ! virsh -c qemu:///session pool-info default &>/dev/null; then
    echo "Creating default pool for session mode..."
    virsh -c qemu:///session pool-define-as default dir --target "$DEFAULT_POOL_PATH"
    virsh -c qemu:///session pool-build default
    virsh -c qemu:///session pool-start default
    virsh -c qemu:///session pool-autostart default
    echo "✓ Default pool created at $DEFAULT_POOL_PATH"
else
    echo "✓ Default pool already exists"
    virsh -c qemu:///session pool-start default 2>/dev/null || echo "  (already started)"
fi

echo ""
echo "Session libvirt ready!"
echo ""
echo "Note: Session daemon auto-starts when you connect"
echo "Verify with: virsh -c qemu:///session list --all"
