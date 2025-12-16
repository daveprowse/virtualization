#!/bin/bash
# Debug SSH connectivity issues

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

echo "Debug: Testing SSH and cloud-init status"
echo "=========================================="
echo ""

echo "Using SSH key: $SSH_KEY_PATH"
echo ""

echo "Test 1: Basic SSH with all options (what deploy.sh uses)"
echo "---------------------------------------------------------"
echo "Command: ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no -o ConnectTimeout=5 sa@10.42.88.120 'echo SUCCESS'"
echo ""
ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no -o ConnectTimeout=5 sa@10.42.88.120 "echo SUCCESS" 2>&1
echo ""
echo "Exit code: $?"
echo ""

echo "Test 2: Check cloud-init status (what deploy.sh checks)"
echo "--------------------------------------------------------"
echo "Command: ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o ConnectTimeout=5 sa@10.42.88.120 'cloud-init status'"
echo ""
ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no -o ConnectTimeout=5 sa@10.42.88.120 "cloud-init status" 2>&1
echo ""
echo "Exit code: $?"
echo ""

echo "Test 3: What grep is looking for"
echo "---------------------------------"
echo "Looking for: 'status: done'"
echo ""
OUTPUT=$(ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no -o ConnectTimeout=5 sa@10.42.88.120 "cloud-init status" 2>&1)
echo "Full output:"
echo "$OUTPUT"
echo ""
if echo "$OUTPUT" | grep -q "status: done"; then
    echo "✅ Found 'status: done' - cloud-init is complete"
else
    echo "❌ Did NOT find 'status: done'"
    echo ""
    echo "Checking what status actually is:"
    echo "$OUTPUT" | grep "status:"
fi
echo ""

echo "Test 4: SSH with BatchMode (no interactive prompts)"
echo "----------------------------------------------------"
echo "Command: ssh -i $SSH_KEY -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=5 sa@10.42.88.120 'hostname'"
echo ""
ssh $SSH_KEY_OPT -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=5 sa@10.42.88.120 "hostname" 2>&1
echo ""
echo "Exit code: $?"
echo ""

echo "Test 5: Check if we need sudo for cloud-init status"
echo "----------------------------------------------------"
echo "Command: ssh -i $SSH_KEY -o StrictHostKeyChecking=no sa@10.42.88.120 'sudo cloud-init status'"
echo ""
ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no sa@10.42.88.120 "sudo cloud-init status" 2>&1
echo ""
echo "Exit code: $?"
echo ""

echo "Test 6: All 5 servers with test-connectivity.sh options"
echo "---------------------------------------------------------"
for ip in 10.42.88.1 10.42.88.2 10.42.88.120 10.42.88.121 10.42.88.122; do
    printf "%-15s " "$ip:"
    if ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=5 sa@$ip "echo connected" 2>&1 | grep -q "connected"; then
        echo "✅ OK"
    else
        echo "❌ FAILED"
        echo "  Error output:"
        ssh $SSH_KEY_OPT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 sa@$ip "echo connected" 2>&1 | sed 's/^/    /'
    fi
done

echo ""
echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""
echo "If Test 1 works but Test 2 fails:"
echo "  → SSH is fine, but cloud-init command has issues"
echo ""
echo "If Test 2 fails but Test 5 works:"
echo "  → Need to use 'sudo cloud-init status' instead"
echo ""
echo "If Test 6 shows failures:"
echo "  → Check the error messages for each host"
echo ""
