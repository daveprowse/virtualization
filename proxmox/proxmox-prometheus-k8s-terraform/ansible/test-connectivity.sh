#!/bin/bash
# Test SSH connectivity to all nodes before running Ansible

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config.sh"

echo "Testing SSH connectivity to all servers..."
echo ""

# SSH options from config (already includes BatchMode, StrictHostKeyChecking, etc.)

# Test each node individually
nodes=(
  "10.42.88.1:prom1"
  "10.42.88.2:prom2"
  "10.42.88.120:controller"
  "10.42.88.121:worker1"
  "10.42.88.122:worker2"
)

all_ok=true

echo "Standalone Servers:"
for node in "10.42.88.1:prom1" "10.42.88.2:prom2"; do
    IFS=':' read -r ip name <<< "$node"
    
    printf "  %-15s %-12s " "$name" "($ip)"
    
    if ssh $SSH_OPTS -o ConnectTimeout=5 sa@$ip "echo connected" &>/dev/null; then
        echo "✅ OK"
    else
        echo "❌ FAILED"
        all_ok=false
    fi
done

echo ""
echo "MicroK8s Cluster:"
for node in "10.42.88.120:controller" "10.42.88.121:worker1" "10.42.88.122:worker2"; do
    IFS=':' read -r ip name <<< "$node"
    
    printf "  %-15s %-12s " "$name" "($ip)"
    
    if ssh $SSH_OPTS -o ConnectTimeout=5 sa@$ip "echo connected" &>/dev/null; then
        echo "✅ OK"
    else
        echo "❌ FAILED"
        all_ok=false
    fi
done

echo ""

if [ "$all_ok" = true ]; then
    echo "✅ All nodes are accessible!"
    echo ""
    echo "Ready to run:"
    echo "  - For MicroK8s cluster: ansible-playbook microk8s-cluster.yml"
    echo "  - For all servers: ansible all -m ping"
    exit 0
else
    echo "❌ Some nodes are not accessible"
    echo ""
    echo "Troubleshooting:"
    echo "1. Wait a few more minutes for cloud-init to complete"
    echo "2. Check VM console on Proxmox"
    echo "3. Manually SSH: ssh -o StrictHostKeyChecking=no sa@<IP>"
    echo "4. Check cloud-init status: sudo cloud-init status"
    exit 1
fi
