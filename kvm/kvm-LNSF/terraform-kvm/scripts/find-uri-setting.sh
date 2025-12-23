#!/bin/bash
# Find where LIBVIRT_DEFAULT_URI is being set

echo "=== Searching for LIBVIRT_DEFAULT_URI settings ==="
echo ""

echo "1. Shell config files:"
for file in ~/.bashrc ~/.bash_profile ~/.profile ~/.zshrc ~/.zshenv; do
    if [ -f "$file" ]; then
        if grep -q "LIBVIRT_DEFAULT_URI" "$file" 2>/dev/null; then
            echo "  FOUND in $file:"
            grep "LIBVIRT_DEFAULT_URI" "$file"
        fi
    fi
done

echo ""
echo "2. System-wide config:"
if sudo grep -r "LIBVIRT_DEFAULT_URI" /etc/profile.d/ 2>/dev/null; then
    echo "  FOUND in /etc/profile.d/"
else
    echo "  Not found in /etc/profile.d/"
fi

echo ""
echo "3. Current shell environment:"
echo "  LIBVIRT_DEFAULT_URI=$LIBVIRT_DEFAULT_URI"

echo ""
echo "=== FIX ==="
echo "Option 1 (Temporary): Run before terraform:"
echo "  unset LIBVIRT_DEFAULT_URI"
echo "  terraform apply"
echo ""
echo "Option 2 (Permanent): Remove from shell config file"
echo "  Or change to: export LIBVIRT_DEFAULT_URI=qemu:///session"
