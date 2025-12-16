#!/bin/bash

# Manual worker join script (fallback if cloud-init auto-join fails)
# This script manually joins workers to the microK8s cluster

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "═══════════════════════════════════════════════════════════"
echo "MicroK8s Cluster - Manual Worker Join Script"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Check if we can reach the controller
if ! ping -c 1 -W 2 10.42.88.120 &>/dev/null; then
    echo -e "${RED}✗ Cannot reach controller at 10.42.88.120${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Controller is reachable${NC}"
echo ""

# Function to join a worker
join_worker() {
    local worker_ip=$1
    local worker_name=$2
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Joining $worker_name ($worker_ip)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Check if worker is reachable
    if ! ping -c 1 -W 2 $worker_ip &>/dev/null; then
        echo -e "${RED}✗ Cannot reach $worker_name at $worker_ip${NC}"
        return 1
    fi
    
    # Check if worker is already part of the cluster
    if ssh -o StrictHostKeyChecking=no sa@10.42.88.120 "microk8s kubectl get nodes" 2>/dev/null | grep -q "$worker_ip"; then
        echo -e "${YELLOW}⚠ $worker_name is already part of the cluster${NC}"
        return 0
    fi
    
    # Generate join token from controller
    echo "Generating join token from controller..."
    JOIN_CMD=$(ssh -o StrictHostKeyChecking=no sa@10.42.88.120 'sudo microk8s add-node --token-ttl 3600' | grep "microk8s join" | head -1)
    
    if [ -z "$JOIN_CMD" ]; then
        echo -e "${RED}✗ Failed to generate join token${NC}"
        return 1
    fi
    
    echo "Join command generated"
    echo ""
    
    # Join the worker
    echo "Joining $worker_name to cluster..."
    if ssh -o StrictHostKeyChecking=no sa@$worker_ip "sudo $JOIN_CMD --worker" 2>&1 | tee /tmp/join-output.txt; then
        echo -e "${GREEN}✓ $worker_name joined successfully${NC}"
        echo ""
        return 0
    else
        # Check if error is because it's already joined
        if grep -q "already known to dqlite" /tmp/join-output.txt; then
            echo -e "${YELLOW}⚠ $worker_name is already part of the cluster${NC}"
            echo ""
            return 0
        else
            echo -e "${RED}✗ Failed to join $worker_name${NC}"
            echo ""
            return 1
        fi
    fi
}

# Join workers
join_worker "10.42.88.121" "Worker1"
sleep 5
join_worker "10.42.88.122" "Worker2"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Cluster Status"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Show cluster status
echo "Waiting for nodes to be ready..."
sleep 10

ssh -o StrictHostKeyChecking=no sa@10.42.88.120 "microk8s kubectl get nodes -o wide"

echo ""
echo -e "${GREEN}✓ Worker join process complete${NC}"
echo ""
echo "Verify cluster health with:"
echo "  ssh sa@10.42.88.120 'microk8s kubectl get nodes'"
echo "  ssh sa@10.42.88.120 'microk8s kubectl get pods -A'"
echo ""
