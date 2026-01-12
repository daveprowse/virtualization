#!/bin/bash

echo "========================================="
echo "  KVM Infrastructure Status Check"
echo "  'Brave knights checking for VMs...'"
echo "========================================="
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if .env exists
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "ERROR: .env file not found!"
    exit 1
fi

# Load environment variables
set -a
source "$SCRIPT_DIR/.env"
set +a

echo "Checking VM status..."
echo ""

check_vm() {
    local name=$1
    local ip=$2
    local user=$3
    
    printf "%-20s %-15s " "$name" "$ip"
    
    # Try to connect via SSH
    if timeout 3 ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q "${user}@${ip}" exit 2>/dev/null; then
        echo "✓ SSH accessible"
    else
        # Check if VM is running via virsh
        if sudo virsh list --all | grep -q "$name.*running"; then
            echo "⚠ Running but SSH not ready"
        elif sudo virsh list --all | grep -q "$name"; then
            echo "✗ VM exists but not running"
        else
            echo "✗ VM not found"
        fi
    fi
}

check_vm "debserver" "$DEBSERVER_IP" "root"
check_vm "debclient" "$DEBCLIENT_IP" "user"
check_vm "ubuntu-server" "$UBUNTU_SERVER_IP" "user"
check_vm "centos-server" "$CENTOS_SERVER_IP" "user"
check_vm "fed-client" "$FEDORA_CLIENT_IP" "user"
check_vm "opensuse" "$OPENSUSE_IP" "user"

echo ""
echo "========================================="
echo "  'None shall... wait, some shall pass!'"
echo "========================================="
