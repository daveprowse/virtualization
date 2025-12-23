#!/bin/bash
# Check if running in session or system mode

echo "=== Libvirt Mode Diagnostic ==="
echo ""

echo "1. Session daemon status:"
systemctl --user is-active virtqemud.socket 2>/dev/null || echo "  NOT RUNNING"

echo ""
echo "2. Session connection test:"
virsh -c qemu:///session uri 2>/dev/null || echo "  FAILED - session not available"

echo ""
echo "3. Session VMs:"
virsh -c qemu:///session list --all 2>/dev/null || echo "  Cannot list session VMs"

echo ""
echo "4. System VMs (for comparison):"
sudo virsh -c qemu:///system list --all 2>/dev/null | head -5 || echo "  Cannot list system VMs"

echo ""
echo "5. Default pool location:"
echo "  Session should use: ~/.local/share/libvirt/images/"
echo "  System uses: /var/lib/libvirt/images/"

echo ""
echo "6. Check where ISOs are being created:"
ls -la ~/.local/share/libvirt/images/LNSF-*.iso 2>/dev/null && echo "  ✓ Found in session location" || echo "  ✗ Not in session location"
ls -la /var/lib/libvirt/images/LNSF-*.iso 2>/dev/null && echo "  ⚠ Found in SYSTEM location (wrong!)" || echo "  ✓ Not in system location"

echo ""
echo "7. VM volume ownership:"
if [ -f ~/kvm-images/LNSF-debserver.qcow2 ]; then
    OWNER=$(stat -c '%U:%G' ~/kvm-images/LNSF-debserver.qcow2)
    if [ "$OWNER" = "dpro:dpro" ]; then
        echo "  ✓ Owned by dpro:dpro (correct for session)"
    else
        echo "  ✗ Owned by $OWNER (wrong - should be dpro:dpro)"
    fi
else
    echo "  No volumes created yet"
fi

echo ""
echo "=== DIAGNOSIS ==="
SESSION_ACTIVE=$(systemctl --user is-active virtqemud.socket 2>/dev/null)
if [ "$SESSION_ACTIVE" = "active" ]; then
    echo "✓ Session libvirt daemon is running"
else
    echo "✗ Session libvirt daemon is NOT running"
    echo "  Run: ./scripts/start-session-libvirt.sh"
fi

if [ -f /var/lib/libvirt/images/LNSF-debserver-cloudinit.iso ]; then
    echo "✗ ISOs in system location - Terraform is connecting to qemu:///system"
    echo "  This means session mode is NOT working correctly"
elif [ -f ~/.local/share/libvirt/images/LNSF-debserver-cloudinit.iso ]; then
    echo "✓ ISOs in session location - Terraform is correctly using qemu:///session"
fi
