#!/bin/bash
# Check environment variables that might affect libvirt connection

echo "=== Environment Check ==="
echo ""

echo "1. LIBVIRT_DEFAULT_URI:"
if [ -n "$LIBVIRT_DEFAULT_URI" ]; then
    echo "  SET TO: $LIBVIRT_DEFAULT_URI"
    if [ "$LIBVIRT_DEFAULT_URI" = "qemu:///system" ]; then
        echo "  ⚠️  WARNING: This will override Terraform provider URI!"
        echo "  Run: unset LIBVIRT_DEFAULT_URI"
    fi
else
    echo "  Not set (good)"
fi

echo ""
echo "2. Current virsh default connection:"
virsh uri 2>/dev/null || echo "  No default"

echo ""
echo "3. Session connection test:"
virsh -c qemu:///session uri

echo ""
echo "4. System connection test (for comparison):"
sudo virsh -c qemu:///system uri

echo ""
echo "5. Check for config files that set default URI:"
if [ -f ~/.config/libvirt/libvirt.conf ]; then
    echo "  ~/.config/libvirt/libvirt.conf exists:"
    grep -v "^#" ~/.config/libvirt/libvirt.conf | grep . || echo "  (empty or all comments)"
else
    echo "  ~/.config/libvirt/libvirt.conf not found"
fi

if [ -f /etc/libvirt/libvirt.conf ]; then
    echo "  /etc/libvirt/libvirt.conf exists:"
    sudo grep -v "^#" /etc/libvirt/libvirt.conf | grep uri || echo "  (no uri setting)"
fi

echo ""
echo "=== DIAGNOSIS ==="
if [ -n "$LIBVIRT_DEFAULT_URI" ] && [ "$LIBVIRT_DEFAULT_URI" != "qemu:///session" ]; then
    echo "✗ LIBVIRT_DEFAULT_URI is set and will override Terraform provider URI"
    echo "  FIX: unset LIBVIRT_DEFAULT_URI"
    echo "  Or add to deploy.sh: export LIBVIRT_DEFAULT_URI=qemu:///session"
else
    echo "✓ No conflicting environment variables found"
fi
