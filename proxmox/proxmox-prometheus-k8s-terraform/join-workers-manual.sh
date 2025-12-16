#!/bin/bash
# Manual Worker Join Script
# MicroK8s is already installed, just need to join workers

set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

echo "Joining workers to MicroK8s cluster..."
echo ""

echo "Step 1: Generate join token on controller..."
JOIN_CMD=$(ssh -i $SSH_KEY_PATH sa@10.42.88.120 "sudo microk8s add-node --token-ttl 3600" | grep "microk8s join" | head -1)

if [ -z "$JOIN_CMD" ]; then
    echo "❌ Failed to get join command from controller"
    exit 1
fi

echo "✅ Got join command: $JOIN_CMD"
echo ""

echo "Step 2: Join worker1 (10.42.88.121)..."
if ssh -i $SSH_KEY_PATH sa@10.42.88.121 "sudo $JOIN_CMD --worker" 2>&1; then
    echo "✅ Worker1 joined!"
else
    echo "⚠️  Worker1 may already be joined or had an error"
fi
echo ""

# Wait a bit for worker1 to stabilize
sleep 10

echo "Step 3: Generate new join token..."
JOIN_CMD=$(ssh -i $SSH_KEY_PATH sa@10.42.88.120 "sudo microk8s add-node --token-ttl 3600" | grep "microk8s join" | head -1)
echo "✅ Got new join command"
echo ""

echo "Step 4: Join worker2 (10.42.88.122)..."
if ssh -i $SSH_KEY_PATH sa@10.42.88.122 "sudo $JOIN_CMD --worker" 2>&1; then
    echo "✅ Worker2 joined!"
else
    echo "⚠️  Worker2 may already be joined or had an error"
fi
echo ""

# Wait for cluster to stabilize
echo "Step 5: Waiting for cluster to stabilize..."
sleep 15

echo "Step 6: Checking cluster status..."
echo ""
ssh -i $SSH_KEY_PATH sa@10.42.88.120 "sudo microk8s kubectl get nodes"
echo ""

echo "✅ Done! Your MicroK8s cluster is ready!"
echo ""
echo "To verify:"
echo "  ssh -i $SSH_KEY_PATH sa@10.42.88.120"
echo "  microk8s kubectl get nodes"
echo "  microk8s kubectl get pods -A"
